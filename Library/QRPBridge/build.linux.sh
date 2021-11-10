g++ main.cpp ../LibRaw/lib/libraw_mod.linux.a ../libjpeg-turbo/lib/libturbojpeg.linux.a \
-include glibc-fix-header/force_link_glibc_2.23.h \
-o ../../GUI/Asset/Lib/Bin/QRPBridge.so \
-Wall -pedantic -Wextra -Wno-unused-parameter \
-fpic -shared \
-lz \
-Ofast -funroll-loops \
-I./godot-headers -I../LibRaw -I../libjpeg-turbo 
