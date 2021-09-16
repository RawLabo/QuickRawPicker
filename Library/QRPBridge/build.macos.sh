clang++ main.cpp ../LibRaw/lib/libraw_mod.macos.a ../libjpeg-turbo/lib/libturbojpeg.macos.a \
-o ../../GUI/Asset/Lib/Bin/QRPBridge.dylib \
-std=c++17 -Wall -pedantic -Wextra -Wno-unused-parameter \
-arch x86_64 -arch arm64 \
-mmacosx-version-min=10.12 \
-dynamiclib -lz \
-Ofast -funroll-loops \
-I./godot-headers -I../LibRaw -I../libjpeg-turbo 