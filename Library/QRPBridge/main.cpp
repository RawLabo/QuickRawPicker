#include <string>
#include <gdnative_api_struct.gen.h>
#include <libraw/libraw.h>
#include <turbojpeg.h>

const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;

#if _WINDLL
#include <locale>
#include <codecvt>
inline std::wstring char2wchar(const char *data)
{
	std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;
	std::wstring result = converter.from_bytes(data);
	return result;
}
#endif

inline void print(const char *data)
{
	godot_string x;
	api->godot_string_new(&x);
	api->godot_string_parse_utf8(&x, data);
	api->godot_print(&x);

	api->godot_string_destroy(&x);
}
inline void print(int value)
{
	godot_string x;
	api->godot_string_new(&x);
	api->godot_string_parse_utf8(&x, std::to_string(value).c_str());
	api->godot_print(&x);

	api->godot_string_destroy(&x);
}
inline void print(double value)
{
	godot_string x;
	api->godot_string_new(&x);
	api->godot_string_parse_utf8(&x, std::to_string(value).c_str());
	api->godot_print(&x);

	api->godot_string_destroy(&x);
}

inline void string2var(const char *data, godot_variant *dst, int len = -1)
{
	godot_string tmp;
	api->godot_string_new(&tmp);
	if (len > 0)
		api->godot_string_parse_utf8_with_len(&tmp, data, len);
	else
		api->godot_string_parse_utf8(&tmp, data);

	api->godot_variant_new_string(dst, &tmp);

	api->godot_string_destroy(&tmp);
}

inline const char *var2char_ptr(godot_variant *var)
{
	godot_string gd_str = api->godot_variant_as_string(var);
	godot_char_string gd_c_str = api->godot_string_utf8(&gd_str);

	const char *ret = api->godot_char_string_get_data(&gd_c_str);

	return ret;
}

inline void pool_byte_copy(godot_variant *dst, const void *src, int size)
{
	godot_pool_byte_array tmp;
	api->godot_pool_byte_array_new(&tmp);
	api->godot_pool_byte_array_resize(&tmp, size);
	godot_pool_byte_array_write_access *ptr_access = api->godot_pool_byte_array_write(&tmp);
	uint8_t *tmp_ptr = api->godot_pool_byte_array_write_access_ptr(ptr_access);
	memcpy(tmp_ptr, src, size);

	// set
	api->godot_variant_new_pool_byte_array(dst, &tmp);

	// clean up
	api->godot_pool_byte_array_write_access_destroy(ptr_access);
	api->godot_pool_byte_array_destroy(&tmp);
}

inline std::string get_hex(char *data, int start, int len)
{
	char const hex_chars[16] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
	std::string result;
	for (int i = start; i < start + len; ++i)
	{
		char const byte = data[i];

		result += hex_chars[(byte & 0xF0) >> 4];
		result += hex_chars[(byte & 0x0F) >> 0];
		result += " ";
	}

	return result;
}

int get_pana_addr_offset(char *start_addr, int16_t count, uint16_t target_tag)
{
	int result = 0;
	for (int i = 0; i < count; ++i)
	{
		uint16_t tag;
		memcpy(&tag, start_addr + 12 * i, sizeof(tag));
		if (tag == target_tag)
		{
			memcpy(&result, start_addr + 12 * i + 8, sizeof(result));
			break;
		}
	}
	return result;
}
inline void focus_location_fetch(godot_variant *focus_loc, const LibRaw *lr_ptr)
{
	godot_array loc_arr;
	api->godot_array_new(&loc_arr);

	godot_variant x, y;

	ushort width, height, left, top;
	bool af_data_valid = false;

	switch (lr_ptr->imgdata.idata.maker_index)
	{
	case LibRaw_cameramaker_index::LIBRAW_CAMERAMAKER_Panasonic:
	{
		const unsigned char offset = 0xc;

		int16_t entity_count;
		memcpy(&entity_count, lr_ptr->imgdata.thumbnail.thumb + 20, sizeof(entity_count));
		int ExifOffset = get_pana_addr_offset(lr_ptr->imgdata.thumbnail.thumb + 22, entity_count, 0x8769);
		if (ExifOffset == 0)
			break;

		auto addr_exif_start = lr_ptr->imgdata.thumbnail.thumb + offset + ExifOffset;

		int16_t exif_count;
		memcpy(&exif_count, addr_exif_start, sizeof(exif_count));
		int MakerNotesOffset = get_pana_addr_offset(addr_exif_start + 2, exif_count, 0x927c);
		if (MakerNotesOffset == 0)
			break;

		auto addr_makernote_start = lr_ptr->imgdata.thumbnail.thumb + offset + MakerNotesOffset;

		int16_t makernote_count;
		memcpy(&makernote_count, addr_makernote_start + 12, sizeof(makernote_count));
		int AFPointPositionOffset = get_pana_addr_offset(addr_makernote_start + 14, makernote_count, 0x004d);
		if (AFPointPositionOffset == 0)
			break;

		int p_left, p_width, p_top, p_height;
		memcpy(&p_left, lr_ptr->imgdata.thumbnail.thumb + offset + AFPointPositionOffset, sizeof(p_left));
		memcpy(&p_width, lr_ptr->imgdata.thumbnail.thumb + offset + AFPointPositionOffset + 4, sizeof(p_width));
		memcpy(&p_top, lr_ptr->imgdata.thumbnail.thumb + offset + AFPointPositionOffset + 8, sizeof(p_top));
		memcpy(&p_height, lr_ptr->imgdata.thumbnail.thumb + offset + AFPointPositionOffset + 12, sizeof(p_height));

		af_data_valid = true;
		width = lr_ptr->imgdata.sizes.iwidth;
		height = lr_ptr->imgdata.sizes.iheight;
		left = width * p_left / p_width;
		top = height * p_top / p_height;

		break;
	}
	case LibRaw_cameramaker_index::LIBRAW_CAMERAMAKER_Canon:
	{
		auto afdata = lr_ptr->imgdata.makernotes.common.afdata;
		int16_t NumAFPoints;
		int16_t AFAreaXPosition = 0;
		int16_t AFAreaYPosition = 0;
		int x_count = 0, y_count = 0;

		memcpy(&NumAFPoints, afdata->AFInfoData + 4, sizeof(NumAFPoints));
		// print(get_hex(afdata->AFInfoData, 16 + NumAFPoints * 2 * 4, 12).c_str());

		for (int i = 0; i < NumAFPoints * 2; i += 2)
		{
			int16_t tmp_x, tmp_y;
			memcpy(&tmp_x, afdata->AFInfoData + 16 + NumAFPoints * 2 * 2 + i, sizeof(tmp_x));
			memcpy(&tmp_y, afdata->AFInfoData + 16 + NumAFPoints * 2 * 3 + i, sizeof(tmp_y));

			if (tmp_x > 0)
			{
				AFAreaXPosition += tmp_x;
				x_count += 1;
			}
			if (tmp_y > 0)
			{
				AFAreaYPosition += tmp_y;
				y_count += 1;
			}
			break;
		}

		if (x_count > 0 && y_count > 0)
		{
			af_data_valid = true;
			width = lr_ptr->imgdata.sizes.iwidth;
			height = lr_ptr->imgdata.sizes.iheight;
			left = width / 2 + AFAreaXPosition / x_count;
			top = height / 2 + AFAreaYPosition / y_count;
		}

		break;
	}
	case LibRaw_cameramaker_index::LIBRAW_CAMERAMAKER_Nikon:
	{
		auto afdata = lr_ptr->imgdata.makernotes.common.afdata;
		if (afdata->AFInfoData_version >= 300)
		{
			int16_t AFImageWidth;
			int16_t AFImageHeight;
			int16_t AFAreaXPosition;
			int16_t AFAreaYPosition;
			memcpy(&AFImageWidth, afdata->AFInfoData + 38, sizeof(AFImageWidth));
			memcpy(&AFImageHeight, afdata->AFInfoData + 40, sizeof(AFImageHeight));
			memcpy(&AFAreaXPosition, afdata->AFInfoData + 42, sizeof(AFAreaXPosition));
			memcpy(&AFAreaYPosition, afdata->AFInfoData + 44, sizeof(AFAreaYPosition));

			if (AFImageWidth > 0 && AFImageHeight > 0)
			{
				af_data_valid = true;

				width = AFImageWidth;
				height = AFImageHeight;
				left = AFAreaXPosition;
				top = AFAreaYPosition;
			}
		}
		break;
	}
	case LibRaw_cameramaker_index::LIBRAW_CAMERAMAKER_Olympus:
	{
		width = lr_ptr->imgdata.sizes.iwidth;
		height = lr_ptr->imgdata.sizes.iheight;
		left = (ushort)(width * lr_ptr->imgdata.makernotes.olympus.AFPointSelected[1]);
		top = (ushort)(height * lr_ptr->imgdata.makernotes.olympus.AFPointSelected[2]);

		if (left != 0 || top != 0)
			af_data_valid = true;
		break;
	}
	case LibRaw_cameramaker_index::LIBRAW_CAMERAMAKER_Sony:
	{
		auto focus_loc = lr_ptr->imgdata.makernotes.sony.FocusLocation;
		width = focus_loc[0];
		height = focus_loc[1];
		left = focus_loc[2];
		top = focus_loc[3];

		if (width != 0)
			af_data_valid = true;
		break;
	}
	}

	if (af_data_valid)
	{
		int pos_x, pos_y;

		switch (lr_ptr->imgdata.sizes.flip)
		{
		case 5:
			pos_x = top - height / 2;
			pos_y = width / 2 - left;
			break;
		case 6:
			pos_x = height / 2 - top;
			pos_y = left - width / 2;
			break;
		case 3:
			pos_x = width / 2 - left;
			pos_y = height / 2 - top;
			break;
		default:
			pos_x = left - width / 2;
			pos_y = top - height / 2;
			break;
		}

		api->godot_variant_new_int(&x, pos_x);
		api->godot_variant_new_int(&y, pos_y);
		api->godot_array_append(&loc_arr, &x);
		api->godot_array_append(&loc_arr, &y);
	}

	api->godot_variant_new_array(focus_loc, &loc_arr);

	api->godot_variant_destroy(&x);
	api->godot_variant_destroy(&y);
	api->godot_array_destroy(&loc_arr);
}

inline void info_fetch(godot_variant *info, const LibRaw *lr_ptr)
{
	godot_array info_arr;
	api->godot_array_new(&info_arr);

	godot_variant width, height, aperture, shutter_speed, iso_speed, focal_len, timestamp, lens_info, maker, model, xmp, focus_loc;

	api->godot_variant_new_int(&width, lr_ptr->imgdata.sizes.iwidth);
	api->godot_variant_new_int(&height, lr_ptr->imgdata.sizes.iheight);
	api->godot_variant_new_real(&aperture, lr_ptr->imgdata.other.aperture);
	api->godot_variant_new_real(&shutter_speed, lr_ptr->imgdata.other.shutter);
	api->godot_variant_new_real(&iso_speed, lr_ptr->imgdata.other.iso_speed);
	api->godot_variant_new_real(&focal_len, lr_ptr->imgdata.other.focal_len);
	api->godot_variant_new_int(&timestamp, lr_ptr->imgdata.other.timestamp);
	string2var(&lr_ptr->imgdata.idata.make[0], &maker);
	string2var(&lr_ptr->imgdata.idata.model[0], &model);
	string2var(&lr_ptr->imgdata.lens.Lens[0], &lens_info);
	string2var(lr_ptr->imgdata.idata.xmpdata, &xmp, lr_ptr->imgdata.idata.xmplen);
	focus_location_fetch(&focus_loc, lr_ptr);

	api->godot_array_append(&info_arr, &width);
	api->godot_array_append(&info_arr, &height);
	api->godot_array_append(&info_arr, &aperture);
	api->godot_array_append(&info_arr, &shutter_speed);
	api->godot_array_append(&info_arr, &iso_speed);
	api->godot_array_append(&info_arr, &focal_len);
	api->godot_array_append(&info_arr, &timestamp);
	api->godot_array_append(&info_arr, &maker);
	api->godot_array_append(&info_arr, &model);
	api->godot_array_append(&info_arr, &lens_info);
	api->godot_array_append(&info_arr, &xmp);
	api->godot_array_append(&info_arr, &focus_loc);

	// set
	api->godot_variant_new_array(info, &info_arr);

	// clean up
	api->godot_variant_destroy(&width);
	api->godot_variant_destroy(&height);
	api->godot_variant_destroy(&aperture);
	api->godot_variant_destroy(&shutter_speed);
	api->godot_variant_destroy(&iso_speed);
	api->godot_variant_destroy(&focal_len);
	api->godot_variant_destroy(&timestamp);
	api->godot_variant_destroy(&maker);
	api->godot_variant_destroy(&model);
	api->godot_variant_destroy(&lens_info);
	api->godot_variant_destroy(&xmp);
	api->godot_variant_destroy(&focus_loc);

	api->godot_array_destroy(&info_arr);
}

void _get_info_with_thumb(const char *path, godot_variant *info, godot_variant *data)
{
	LibRaw *lr_ptr = new LibRaw();

#if _WINDLL
	int result = lr_ptr->open_file(char2wchar(path).c_str());
#else
	int result = lr_ptr->open_file(path);
#endif

	if (result == 0)
	{
		int unpack_result = lr_ptr->unpack_thumb();
		info_fetch(info, lr_ptr);
		if (unpack_result == 0)
		{
			libraw_processed_image_t *image = lr_ptr->dcraw_make_mem_thumb();

			int flip = lr_ptr->imgdata.sizes.flip;
			if (flip != 0)
			{
				unsigned long dstSizes = 0;
				unsigned char *dstBufs = nullptr;

				tjhandle _jpegRotator = tjInitTransform();
				tjtransform transform;
				transform.customFilter = 0;
				if (flip == 3)
					transform.op = TJXOP_ROT180;
				else if (flip == 5)
					transform.op = TJXOP_ROT270;
				else if (flip == 6)
					transform.op = TJXOP_ROT90;

				tjTransform(_jpegRotator, (unsigned char *)&image->data, image->data_size, 1, &dstBufs, &dstSizes, &transform, TJFLAG_FASTDCT);
				pool_byte_copy(data, dstBufs, dstSizes);

				tjDestroy(_jpegRotator);
				tjFree(dstBufs);
			}
			else
			{
				pool_byte_copy(data, &image->data, image->data_size);
			}

			LibRaw::dcraw_clear_mem(image);
		}
	}

	lr_ptr->recycle();
	delete lr_ptr;
}

void _get_image_data(const char *path, godot_variant *data, int bps, bool set_half, bool auto_bright, int output_color)
{
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

	if (!auto_bright)
	{
		lr_ptr->imgdata.params.no_auto_bright = 1;
		lr_ptr->imgdata.params.bright = 1;
		lr_ptr->imgdata.params.gamm[0] = 1;
		lr_ptr->imgdata.params.gamm[1] = 1;
	}

#if _WINDLL
	int result = lr_ptr->open_file(char2wchar(path).c_str());
#else
	int result = lr_ptr->open_file(path);
#endif

	if (result == 0)
	{
		lr_ptr->unpack();
		lr_ptr->dcraw_process();

		libraw_processed_image_t *image = lr_ptr->dcraw_make_mem_image();

		pool_byte_copy(data, &image->data, image->data_size);

		LibRaw::dcraw_clear_mem(image);
	}

	lr_ptr->recycle();
	delete lr_ptr;
}

extern "C"
{
	void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options)
	{
		api = p_options->api_struct;

		for (unsigned int i = 0; i < api->num_extensions; i++)
		{
			switch (api->extensions[i]->type)
			{
			case GDNATIVE_EXT_NATIVESCRIPT:
			{
				nativescript_api = (godot_gdnative_ext_nativescript_api_struct *)api->extensions[i];
			};
			break;
			default:
				break;
			};
		};
	}
	void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options)
	{
		api = NULL;
		nativescript_api = NULL;
	}

	GDCALLINGCONV void *default_ctor(godot_object *p_instance, void *p_method_data) { return NULL; }
	GDCALLINGCONV void default_dector(godot_object *p_instance, void *p_method_data, void *p_user_data) {}

	godot_variant get_info_with_thumb(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args)
	{
		const char *path = var2char_ptr(*p_args);

		_get_info_with_thumb(path, *(p_args + 1), *(p_args + 2));
		return **p_args;
	}

	godot_variant get_image_data(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args)
	{
		const char *path = var2char_ptr(*p_args);
		int bps = (int)api->godot_variant_as_int(*(p_args + 2));
		bool set_half = api->godot_variant_as_bool(*(p_args + 3));
		bool auto_bright = api->godot_variant_as_bool(*(p_args + 4));
		int output_color = api->godot_variant_as_int(*(p_args + 5));

		_get_image_data(path, *(p_args + 1), bps, set_half, auto_bright, output_color);
		return **p_args;
	}

	void GDN_EXPORT godot_nativescript_init(void *p_handle)
	{
		godot_instance_create_func create = {NULL, NULL, NULL};
		create.create_func = &default_ctor;
		godot_instance_destroy_func destroy = {NULL, NULL, NULL};
		destroy.destroy_func = &default_dector;
		nativescript_api->godot_nativescript_register_class(p_handle, "QRPBridge", "Reference", create, destroy);

		godot_method_attributes attributes = {GODOT_METHOD_RPC_MODE_DISABLED};

		godot_instance_method get_image_data_m = {NULL, NULL, NULL};
		get_image_data_m.method = &get_image_data;
		nativescript_api->godot_nativescript_register_method(p_handle, "QRPBridge", "get_image_data", attributes, get_image_data_m);

		godot_instance_method get_info_with_thumb_m = {NULL, NULL, NULL};
		get_info_with_thumb_m.method = &get_info_with_thumb;
		nativescript_api->godot_nativescript_register_method(p_handle, "QRPBridge", "get_info_with_thumb", attributes, get_info_with_thumb_m);
	}
}