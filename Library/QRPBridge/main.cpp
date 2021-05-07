#include <gdnative_api_struct.gen.h>
#include <string.h>
#include <stdio.h>
#include <libraw/libraw.h>
#include <exiv2/exiv2.hpp>

const godot_gdnative_core_api_struct* api = NULL;
const godot_gdnative_ext_nativescript_api_struct* nativescript_api = NULL;

inline void print(const char* data) {
	godot_string x;
	api->godot_string_new(&x);
	api->godot_string_parse_utf8(&x, data);
	api->godot_print(&x);
	
	api->godot_string_destroy(&x);
}

inline void string2var(const char* data, godot_variant* var) {
	godot_string tmp;
	api->godot_string_new(&tmp);
	api->godot_string_parse_utf8(&tmp, data);
	api->godot_variant_new_string(var, &tmp);
	
	api->godot_string_destroy(&tmp);
}

inline const char* var2char_ptr(godot_variant* var) {
	godot_string gd_str = api->godot_variant_as_string(var);
	godot_char_string gd_c_str = api->godot_string_utf8(&gd_str);
	const char* ret = api->godot_char_string_get_data(&gd_c_str);
	
	api->godot_char_string_destroy(&gd_c_str);
	api->godot_string_destroy(&gd_str);

	return ret;
}

void get_exif(const char* path, godot_array* ret) {
	Exiv2::Image::AutoPtr image = Exiv2::ImageFactory::open(path);
	image->readMetadata();

	Exiv2::ExifData& exif_data = image->exifData();

	Exiv2::ExifData::const_iterator tags[] = { 
		Exiv2::fNumber(exif_data),
		Exiv2::isoSpeed(exif_data),
		Exiv2::exposureTime(exif_data)
	};

	for (auto& item : tags) {
		godot_variant box;
		string2var(item->value().toString().c_str(), &box);
		api->godot_array_append(ret, &box);

		// clean up
		api->godot_variant_destroy(&box);
	}
}

void get_image(const char* path, godot_variant* width, godot_variant* height, godot_variant* data) {
	LibRaw *lr_ptr = new LibRaw();

	lr_ptr->imgdata.params.fbdd_noiserd = 0;
	lr_ptr->imgdata.params.user_qual = 2;
	lr_ptr->imgdata.params.output_bps = 16;

	int result = lr_ptr->open_file(path);
	lr_ptr->unpack();
	lr_ptr->dcraw_process();

	libraw_processed_image_t* image = lr_ptr->dcraw_make_mem_image();

	godot_pool_byte_array tmp;
	api->godot_pool_byte_array_new(&tmp);
	api->godot_pool_byte_array_resize(&tmp, image->data_size);
	godot_pool_byte_array_write_access* ptr_access = api->godot_pool_byte_array_write(&tmp);
	uint8_t* tmp_ptr = api->godot_pool_byte_array_write_access_ptr(ptr_access);

	memcpy(tmp_ptr, &image->data, image->data_size);

	api->godot_variant_new_int(width, image->width);
	api->godot_variant_new_int(height, image->height);
	api->godot_variant_new_pool_byte_array(data, &tmp);
	
	// clean up
	api->godot_pool_byte_array_write_access_destroy(ptr_access);
	api->godot_pool_byte_array_destroy(&tmp);

	LibRaw::dcraw_clear_mem(image);
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
	
	godot_variant get_exif_info(godot_object* p_instance, void* p_method_data, void* p_user_data, int p_num_args, godot_variant** p_args) {
		const char* path = var2char_ptr(*p_args);

		godot_array ret;
		api->godot_array_new(&ret);

		get_exif(path, &ret);

		godot_variant result;
		api->godot_variant_new_array(&result, &ret);

		// clean up
		api->godot_array_destroy(&ret);

		return result;
	}

	godot_variant get_image_data(godot_object* p_instance, void* p_method_data, void* p_user_data, int p_num_args, godot_variant** p_args) {
		const char* path = var2char_ptr(*p_args);

		godot_variant width;
		godot_variant height;
		godot_variant data;
		get_image(path, &width, &height, &data);

		godot_array ret;
		api->godot_array_new(&ret);

		api->godot_array_push_back(&ret, &width);
		api->godot_array_push_back(&ret, &height);
		api->godot_array_push_back(&ret, &data);

		godot_variant result;
		api->godot_variant_new_array(&result, &ret);

		// clean up
		api->godot_variant_destroy(&width);
		api->godot_variant_destroy(&height);
		api->godot_variant_destroy(&data);
		api->godot_array_destroy(&ret);

		return result;
	}

	void GDN_EXPORT godot_nativescript_init(void* p_handle) {
		godot_instance_create_func create = { NULL, NULL, NULL };
		create.create_func = &default_ctor;
		godot_instance_destroy_func destroy = { NULL, NULL, NULL };
		destroy.destroy_func = &default_dector;
		nativescript_api->godot_nativescript_register_class(p_handle, "QRPBridge", "Reference", create, destroy);

		godot_method_attributes attributes = { GODOT_METHOD_RPC_MODE_DISABLED };

		godot_instance_method get_data = { NULL, NULL, NULL };
		get_data.method = &get_image_data;
		nativescript_api->godot_nativescript_register_method(p_handle, "QRPBridge", "get_image_data", attributes, get_data);

		godot_instance_method get_exif = { NULL, NULL, NULL };
		get_exif.method = &get_exif_info;
		nativescript_api->godot_nativescript_register_method(p_handle, "QRPBridge", "get_exif_info", attributes, get_exif);
	}

}