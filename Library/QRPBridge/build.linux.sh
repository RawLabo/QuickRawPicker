g++ -fpic -shared -flinker-output=dyn -O3 -o ../../GUI/Asset/Lib/Bin/QRPBridge.so -I./godot-headers -I../Exiv2 -I../LibRaw main.cpp ../LibRaw/bin/libraw_mod.linux.a ../Exiv2/bin/libexiv2.linux.a
