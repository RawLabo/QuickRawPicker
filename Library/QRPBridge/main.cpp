#include <string>
#include <codecvt>
#include <gdnative_api_struct.gen.h>
#include <libraw/libraw.h>
#include <turbojpeg.h>

const godot_gdnative_core_api_struct* api = NULL;
const godot_gdnative_ext_nativescript_api_struct* nativescript_api = NULL;

inline std::wstring char2wchar(const char* data) {
	std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
	std::wstring result = converter.from_bytes(data);
	return result;
}

inline void print(const char* data) {
	godot_string x;
	api->godot_string_new(&x);
	api->godot_string_parse_utf8(&x, data);
	api->godot_print(&x);
	
	api->godot_string_destroy(&x);
}
inline void print(int value) {
	godot_string x;
	api->godot_string_new(&x);
	api->godot_string_parse_utf8(&x, std::to_string(value).c_str());
	api->godot_print(&x);

	api->godot_string_destroy(&x);
}

inline void string2var(const char* data, godot_variant* dst, int len = -1) {
	godot_string tmp;
	api->godot_string_new(&tmp);
	if (len > 0)
		api->godot_string_parse_utf8_with_len(&tmp, data, len);
	else
		api->godot_string_parse_utf8(&tmp, data);

	api->godot_variant_new_string(dst, &tmp);

	api->godot_string_destroy(&tmp);
}

inline const char* var2char_ptr(godot_variant* var) {
	godot_string gd_str = api->godot_variant_as_string(var);
	godot_char_string gd_c_str = api->godot_string_utf8(&gd_str);

	const char* ret = api->godot_char_string_get_data(&gd_c_str);

	return ret;
}

inline void pool_byte_copy(godot_variant* dst, const void* src, int size) {
	godot_pool_byte_array tmp;
	api->godot_pool_byte_array_new(&tmp);
	api->godot_pool_byte_array_resize(&tmp, size);
	godot_pool_byte_array_write_access* ptr_access = api->godot_pool_byte_array_write(&tmp);
	uint8_t* tmp_ptr = api->godot_pool_byte_array_write_access_ptr(ptr_access);
	memcpy(tmp_ptr, src, size);

	// set
	api->godot_variant_new_pool_byte_array(dst, &tmp);

	// clean up
	api->godot_pool_byte_array_write_access_destroy(ptr_access);
	api->godot_pool_byte_array_destroy(&tmp);
}

inline void info_fetch(godot_variant* info, const LibRaw* lr_ptr) {
	godot_array info_arr;
	api->godot_array_new(&info_arr);

	godot_variant width, height, aperture, shutter_speed, iso_speed, focal_len, lens_info, maker, model, xmp;

	api->godot_variant_new_int(&width, lr_ptr->imgdata.sizes.iwidth);
	api->godot_variant_new_int(&height, lr_ptr->imgdata.sizes.iheight);
	api->godot_variant_new_real(&aperture, lr_ptr->imgdata.other.aperture);
	api->godot_variant_new_real(&shutter_speed, lr_ptr->imgdata.other.shutter);
	api->godot_variant_new_real(&iso_speed, lr_ptr->imgdata.other.iso_speed);
	api->godot_variant_new_real(&focal_len, lr_ptr->imgdata.other.focal_len);
	string2var(&lr_ptr->imgdata.idata.make[0], &maker);
	string2var(&lr_ptr->imgdata.idata.model[0], &model);
	string2var(&lr_ptr->imgdata.lens.Lens[0], &lens_info);
	string2var(lr_ptr->imgdata.idata.xmpdata, &xmp, lr_ptr->imgdata.idata.xmplen);
	
	api->godot_array_append(&info_arr, &width);
	api->godot_array_append(&info_arr, &height);
	api->godot_array_append(&info_arr, &aperture);
	api->godot_array_append(&info_arr, &shutter_speed);
	api->godot_array_append(&info_arr, &iso_speed);
	api->godot_array_append(&info_arr, &focal_len);
	api->godot_array_append(&info_arr, &maker);
	api->godot_array_append(&info_arr, &model);
	api->godot_array_append(&info_arr, &lens_info);
	api->godot_array_append(&info_arr, &xmp);

	// set
	api->godot_variant_new_array(info, &info_arr);

	// clean up
	api->godot_variant_destroy(&width);
	api->godot_variant_destroy(&height);
	api->godot_variant_destroy(&aperture);
	api->godot_variant_destroy(&shutter_speed);
	api->godot_variant_destroy(&iso_speed);
	api->godot_variant_destroy(&focal_len);
	api->godot_variant_destroy(&maker);
	api->godot_variant_destroy(&model);
	api->godot_variant_destroy(&lens_info);
	api->godot_variant_destroy(&xmp);

	api->godot_array_destroy(&info_arr);
}

void _get_info_with_thumb(const char* path, godot_variant* info, godot_variant* data) {
	LibRaw* lr_ptr = new LibRaw();

	int result = lr_ptr->open_file(char2wchar(path).c_str());
	if (result == 0) {
		info_fetch(info, lr_ptr);

		int unpack_result = lr_ptr->unpack_thumb();
		if (unpack_result == 0) {
			libraw_processed_image_t* image = lr_ptr->dcraw_make_mem_thumb();

			int flip = lr_ptr->imgdata.sizes.flip;
			if (flip != 0) {
				unsigned long dstSizes = 0;
				unsigned char* dstBufs = nullptr;

				tjhandle _jpegRotator = tjInitTransform();
				tjtransform transform;
				transform.customFilter = 0;
				if (flip == 3)
					transform.op = TJXOP_ROT180;
				else if (flip == 5)
					transform.op = TJXOP_ROT270;
				else if (flip == 6)
					transform.op = TJXOP_ROT90;

				tjTransform(_jpegRotator, (unsigned char*)&image->data, image->data_size, 1, &dstBufs, &dstSizes, &transform, TJFLAG_FASTDCT);
				pool_byte_copy(data, dstBufs, dstSizes);

				tjDestroy(_jpegRotator);
				tjFree(dstBufs);
			}
			else {
				pool_byte_copy(data, &image->data, image->data_size);
			}

			LibRaw::dcraw_clear_mem(image);
		}
	}
	
	lr_ptr->recycle();
	delete lr_ptr;
}

void _get_image_data(const char* path, godot_variant* data, int bps, bool set_half, bool auto_bright, int output_color) {
	LibRaw *lr_ptr = new LibRaw();

	lr_ptr->imgdata.params.fbdd_noiserd = 0;
	lr_ptr->imgdata.params.highlight = 0;
	lr_ptr->imgdata.params.user_qual = 2;
	lr_ptr->imgdata.params.output_bps = bps;
	lr_ptr->imgdata.params.output_color = output_color;
	lr_ptr->imgdata.params.use_camera_wb = 1;
	//lr_ptr->imgdata.params.no_auto_scale = 1;
	//lr_ptr->imgdata.params.no_interpolation = 1;

	if (set_half)
		lr_ptr->imgdata.params.half_size = 1;

	if (!auto_bright) {
		lr_ptr->imgdata.params.no_auto_bright = 1;
		lr_ptr->imgdata.params.gamm[0] = 0;
		lr_ptr->imgdata.params.gamm[1] = 1000;
	}

	int result = lr_ptr->open_file(char2wchar(path).c_str());
	if (result == 0) {
		lr_ptr->unpack();
		lr_ptr->dcraw_process();

		libraw_processed_image_t* image = lr_ptr->dcraw_make_mem_image();

		pool_byte_copy(data, &image->data, image->data_size);

		LibRaw::dcraw_clear_mem(image);
	}

	lr_ptr->recycle();
	delete lr_ptr;
}

extern "C" {
	void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options* p_options) {
		api = p_options->api_struct;

		for (unsigned int i = 0; i < api->num_extensions; i++) {
			switch (api->extensions[i]->type) {
			case GDNATIVE_EXT_NATIVESCRIPT: {
				nativescript_api = (godot_gdnative_ext_nativescript_api_struct*)api->extensions[i];
			}; break;
			default:
				break;
			};
		};
	}
	void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options* p_options) {
		api = NULL;
		nativescript_api = NULL;
	}

	GDCALLINGCONV void* default_ctor(godot_object* p_instance, void* p_method_data) { return NULL; }
	GDCALLINGCONV void default_dector(godot_object* p_instance, void* p_method_data, void* p_user_data) {}
	
	godot_variant get_info_with_thumb(godot_object* p_instance, void* p_method_data, void* p_user_data, int p_num_args, godot_variant** p_args) {
		const char* path = var2char_ptr(*p_args);

		_get_info_with_thumb(path, *(p_args + 1), *(p_args + 2));
		return **p_args;
	}

	godot_variant get_image_data(godot_object* p_instance, void* p_method_data, void* p_user_data, int p_num_args, godot_variant** p_args) {
		const char* path = var2char_ptr(*p_args);
		int bps = (int)api->godot_variant_as_int(*(p_args + 2));
		bool set_half = api->godot_variant_as_bool(*(p_args + 3));
		bool auto_bright = api->godot_variant_as_bool(*(p_args + 4));
		int output_color = api->godot_variant_as_int(*(p_args + 5));

		_get_image_data(path, *(p_args + 1), bps, set_half, auto_bright, output_color);
		return **p_args;
	}

	void GDN_EXPORT godot_nativescript_init(void* p_handle) {
		godot_instance_create_func create = { NULL, NULL, NULL };
		create.create_func = &default_ctor;
		godot_instance_destroy_func destroy = { NULL, NULL, NULL };
		destroy.destroy_func = &default_dector;
		nativescript_api->godot_nativescript_register_class(p_handle, "QRPBridge", "Reference", create, destroy);

		godot_method_attributes attributes = { GODOT_METHOD_RPC_MODE_DISABLED };

		godot_instance_method get_image_data_m = { NULL, NULL, NULL };
		get_image_data_m.method = &get_image_data;
		nativescript_api->godot_nativescript_register_method(p_handle, "QRPBridge", "get_image_data", attributes, get_image_data_m);

		godot_instance_method get_info_with_thumb_m = { NULL, NULL, NULL };
		get_info_with_thumb_m.method = &get_info_with_thumb;
		nativescript_api->godot_nativescript_register_method(p_handle, "QRPBridge", "get_info_with_thumb", attributes, get_info_with_thumb_m);
	}

}