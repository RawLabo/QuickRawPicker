clang++ main.cpp ../LibRaw/lib/libraw_mod.linux.a ../libjpeg-turbo/lib/libturbojpeg.linux.a \
-o ../../GUI/Asset/Lib/Bin/QRPBridge.dylib \
-Wall -pedantic -Wextra -Wno-unused-parameter \
-arch x86_64 -arch arm64 \
-dynamiclib -lz \
-Ofast -funroll-loops \
-I./godot-headers -I../LibRaw -I../libjpeg-turbo 