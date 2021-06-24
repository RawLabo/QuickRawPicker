g++ main.cpp ../LibRaw/lib/libraw_mod.mingw.a ../libjpeg-turbo/lib/libturbojpeg.mingw.a ^
-o ../../GUI/Asset/Lib/Bin/QRPBridge.dll ^
-D_WINDLL ^
-Wall -pedantic -Wextra -Wno-unused-parameter ^
-static -shared -lWs2_32 -lz ^
-Ofast -funroll-loops ^
-I./godot-headers -I../LibRaw -I../libjpeg-turbo 