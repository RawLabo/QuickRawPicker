# QuickRawPicker
A free and open source program that lets you cull, pick or rate raw photos captured by your camera.

[![CodeFactor](https://www.codefactor.io/repository/github/qdwang/quickrawpicker/badge)](https://www.codefactor.io/repository/github/qdwang/quickrawpicker)
[![GitHub](https://img.shields.io/badge/license-LGPL--2.1-yellow)](./LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/qdwang/QuickRawPicker)](#)

[![GitHub Release Date](https://img.shields.io/github/release-date/qdwang/QuickRawPicker)](https://github.com/qdwang/QuickRawPicker/releases)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/qdwang/QuickRawPicker)](https://github.com/qdwang/QuickRawPicker/releases)
[![GitHub all releases](https://img.shields.io/github/downloads/qdwang/QuickRawPicker/total)](https://github.com/qdwang/QuickRawPicker/releases)
[![platform](https://img.shields.io/badge/platform-win64%20%2F%20linux64%20%2F%20macOS%20universal-green)](#)


## Why QuickRawPicker?
* **To save time.** QuickRawPicker is very fast for checking multiple raw photos at the same time. It is speed oriented and built with C++ and Godot game engine. With the 16-bit texture feature, it is easy to check if the raw photo is overexposed or too noisy in dark areas.
* **To save money.** You can easily use QuickRawPicker as a pre-step to Rawtherapee or Darktable for that QuickRawPicker has XMP and PP3 ratings and is compatible with most free raw editing softwares on the market.
* **Cross platforms.** Most major desktop platforms are natively supported. **(Windows x64 | Linux x64 | macOS Intel / Apple silicon)**
* **Small size and ease of use.** The zip package is only about 30MB, no installation and no complicated setup.

**[🔽Download](https://github.com/qdwang/QuickRawPicker/releases/latest) the latest precompiled binaries.**
> You may need to run `xattr -dr com.apple.quarantine QuickRawPicker.app` to fix the **"file is damaged"** issue under macOS. 
> 
> Please check https://disable-gatekeeper.github.io/ for more info.
> 
![QuickRawPicker-v0 2 0-win-x64](https://user-images.githubusercontent.com/403616/134761572-d35736b2-6af8-4c4e-88da-ef39cae62566.jpg)

## Features
* Compare multiple (up to 100) photos of multiple scales at the same time.
* Read XMP rating score from the raw file, sidecar `.xmp` file or `.pp3` file.
* Write XMP or PP3 rating score to sidecar `.xmp` or `.pp3` file.
* Adjust EV and shift Gamma.
* Draw highlight area and shadow clipping area.
* Display as 16 bit texture on screen.
* Color space setting available.
* Export marked photos and associated files(Like `.JPG` and `.xmp`) by copying.
* Display AF point for different cameras' raw files, including Sony, Panasonic, Canon, Nikon, Olympus.
* 180 degree rotation.

**[👉 Features animations page](./Doc/Features.md)**

## Q&A
1. **Why does my RAW file show black empty content on the screen?** <br> The default renderer is based on GLES3 which may not be compatible with some legacy graphics card. <br>  Try `Fn -> Settings -> Renderer Tab -> switch Renderer from GLES3 to GLES2 -> restart the QuickRawPicker` to fix the problem.

### Shortcuts
**[👉 Shortcuts doc page](./Doc/Shortcuts.md)**

### Settings
**[👉 Settings doc page](./Doc/Settings.md)**

### Building
**[👉 Building doc page](./Doc/Building.md)**

## Workflows
1. **By rating**. By Rating your raw photos in QuickRawPicker, the rating score will be written into the sidecar file `xmp` or `pp3`. And then you can filter and edit them in Adobe Bridge, Lightroom, Darktable or Rawtherapee directly. [demo](https://github.com/qdwang/QuickRawPicker/discussions/4)
2. **By marking and exporting**. By marking your raw photos in QuickRawPicker, you can later export all the marked photo files to a desired folder. Usually this method can used to check the raw files on the SD card directly and export the marked ones to your hard drive on computer. [demo](https://github.com/qdwang/QuickRawPicker/discussions/2)

## Need any help, support or discussion
**[👉 Github discussions](https://github.com/qdwang/QuickRawPicker/discussions)**

## Credits
1. [godot](https://github.com/godotengine/godot) Licensed MIT
2. [LibRaw](https://github.com/LibRaw/LibRaw) Licensed LGPL-2.1
3. [libjpeg-turbo](https://libjpeg-turbo.org/) Licensed BSD
