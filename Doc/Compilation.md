# Compilation

1. You need `git-lfs` installed. https://git-lfs.github.com/
2. Clone the repo: https://github.com/qdwang/QuickRawPicker.git
3. Enter the root directory and run `git lfs pull`. This process will download all the binary library files we need.
4. Download Godot Engine Standard Version. https://godotengine.org/download
5. Import the project in Godot.
6. Press F5 to run the project.


## Libraries

### LibRaw modified version
QuickRawPicker uses a modified version of LibRaw. 

1. Clone the repo: https://github.com/qdwang/LibRaw.git
2. Make sure the correct C++ compiler is installed.
    1. GCC for Linux. You can use this [PPA](https://launchpad.net/~ubuntu-toolchain-r/+archive/ubuntu/test) to fetch the latest GCC.
    2. clang for MacOS. Install though xcode command line tools.
    3. MinGW GCC for Windows. You can download latest version in https://winlibs.com/
3. Run `make -f Makefile.static.linux` for Linux. Run `make -f Makefile.static.macos` for MacOS. `build_mingw.bat` for Windows.

### libjpeg-turbo
You can directly download the prebuilt binary or lib file on the official website. https://sourceforge.net/projects/libjpeg-turbo/files/

### QRPBridge
This comes with the QuickRawPicker project. This bridge library will combine the libraries from LibRaw mod version and libjpeg-turbo and port functions to the Godot engine we use.

1. `cd QuickRawPicker/Library/QRPBridge`
2. Run `build.linux.sh` for Linux. Run `Build.macos.sh` for MacOS. Run `build.mingw.bat` for Windows.
3. A corresponding dynamic library file will be compiled at `GUI/Asset/Lib/Bin/` directory.