clang++ -arch x86_64 -arch arm64 -dynamiclib -O3 -o ../../GUI/Asset/Lib/Bin/QRPBridge.dylib -lz -I./godot-headers -I../LibRaw main.cpp ../LibRaw/bin/libraw_mod.macos.a
