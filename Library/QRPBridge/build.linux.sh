g++ -fpic -shared -flinker-output=dyn -O3 -o ../../GUI/Asset/Lib/Bin/QRPBridge.so -I./godot-headers -I../LibRaw main.cpp ../LibRaw/bin/libraw_mod.linux.a
