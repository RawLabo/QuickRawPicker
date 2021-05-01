#include <gdnative_api_struct.gen.h>
#include <string.h>
#include <stdio.h>
#include "../LibRaw/libraw/libraw.h"

const godot_gdnative_core_api_struct* api = NULL;
const godot_gdnative_ext_nativescript_api_struct* nativescript_api = NULL;

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

		for (int i = 0; i < api->num_extensions; i++) {
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

	GDCALLINGCONV void* simple_constructor(godot_object* p_instance, void* p_method_data) {
		return NULL;
	}
	GDCALLINGCONV void simple_destructor(godot_object* p_instance, void* p_method_data, void* p_user_data) {
	}

	godot_variant simple_get_data(godot_object* p_instance, void* p_method_data, void* p_user_data, int p_num_args, godot_variant** p_args) {
		godot_string file_name = api->godot_variant_as_string(*p_args);
		godot_char_string c_file_name = api->godot_string_utf8(&file_name);
		const char* path = api->godot_char_string_get_data(&c_file_name);

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
		api->godot_string_destroy(&file_name);
		api->godot_char_string_destroy(&c_file_name);
		api->godot_variant_destroy(&width);
		api->godot_variant_destroy(&height);
		api->godot_variant_destroy(&data);
		api->godot_array_destroy(&ret);

		return result;
	}

	//godot_variant simple_get_data(godot_object* p_instance, void* p_method_data, void* p_user_data, int p_num_args, godot_variant** p_args) {
	//	godot_pool_byte_array tmp;
	//	api->godot_pool_byte_array_new(&tmp);

	//	godot_string file_name = api->godot_variant_as_string(*p_args);
	//	godot_char_string v = api->godot_string_utf8(&file_name);
	//	const char* path_c = api->godot_char_string_get_data(&v);

	//	libraw_processed_image_t* image = get_image(path_c);
	//	api->godot_pool_byte_array_resize(&tmp, image->data_size);

	//	godot_pool_byte_array_write_access* ptr_access = api->godot_pool_byte_array_write(&tmp);
	//	uint8_t* ptr = api->godot_pool_byte_array_write_access_ptr(ptr_access);

	//	memcpy(ptr, &image->data, image->data_size);
	//	
	//	godot_array k_ret;
	//	api->godot_array_new(&k_ret);

	//	godot_variant k_width;
	//	api->godot_variant_new_int(&k_width, image->width);
	//	godot_variant k_height;
	//	api->godot_variant_new_int(&k_height, image->height);
	//	godot_variant k_data;
	//	api->godot_variant_new_pool_byte_array(&k_data, &tmp);

	//	api->godot_array_push_back(&k_ret, &k_width);
	//	api->godot_array_push_back(&k_ret, &k_height);
	//	api->godot_array_push_back(&k_ret, &k_data);

	//	godot_variant k_result;
	//	api->godot_variant_new_array(&k_result, &k_ret);

	//	return k_result;
	//}

	void GDN_EXPORT godot_nativescript_init(void* p_handle) {
		godot_instance_create_func create = { NULL, NULL, NULL };
		create.create_func = &simple_constructor;
		godot_instance_destroy_func destroy = { NULL, NULL, NULL };
		destroy.destroy_func = &simple_destructor;
		nativescript_api->godot_nativescript_register_class(p_handle, "QRPBridge", "Reference", create, destroy);

		godot_instance_method get_data = { NULL, NULL, NULL };
		get_data.method = &simple_get_data;
		godot_method_attributes attributes = { GODOT_METHOD_RPC_MODE_DISABLED };
		nativescript_api->godot_nativescript_register_method(p_handle, "QRPBridge", "get_image_data", attributes, get_data);
	}

}