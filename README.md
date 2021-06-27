# QuickRawPicker


[![CodeFactor](https://www.codefactor.io/repository/github/qdwang/quickrawpicker/badge)](https://www.codefactor.io/repository/github/qdwang/quickrawpicker)
[![GitHub](https://img.shields.io/badge/license-LGPL--2.1-yellow)](./LICENSE)
[![GitHub last commit](https://img.shields.io/github/last-commit/qdwang/QuickRawPicker)](#)

[![GitHub Release Date](https://img.shields.io/github/release-date/qdwang/QuickRawPicker)](https://github.com/qdwang/QuickRawPicker/releases)
[![GitHub release (latest by date)](https://img.shields.io/github/v/release/qdwang/QuickRawPicker)](https://github.com/qdwang/QuickRawPicker/releases)
[![GitHub all releases](https://img.shields.io/github/downloads/qdwang/QuickRawPicker/total)](https://github.com/qdwang/QuickRawPicker/releases)
[![platform](https://img.shields.io/badge/platform-win64%20%2F%20linux64%20%2F%20macOS%20universal-green)](#)

[![Discord](https://img.shields.io/discord/856151439053946940?color=%23ea0&label=discord%20support)](https://discord.com/channels/856151439053946940)

QuickRawPicker is a free and open source program that lets you cull, pick or rate raw photos captured by your camera. It is also compatible with the XMP sidecar file used by Adobe Bridge/Lightroom or PP3 sidecar file used by Rawtherapee.

**[🔽Download](https://github.com/qdwang/QuickRawPicker/releases/latest) the latest precompiled binaries.**
> You may need to run `xattr -dr com.apple.quarantine QuickRawPicker.app` to fix the **"file is damaged"** issue under macOS.

![QuickRawPicker-screenshot](https://user-images.githubusercontent.com/403616/122661158-f258e880-d1b9-11eb-9be0-6eb7c0e0175b.jpg)

## Features
* Compare multiple (up to 100) photos of multiple scales at the same time.
* Read XMP rating score from the raw file, sidecar `.xmp` file or `.pp3` file.
* Write XMP or PP3 rating score to sidecar `.xmp` or `.pp3` file.
* Adjust EV and shift Gamma.
* Draw highlight area and shadow area.
* Display as 16 bit texture on screen.
* Display as low contrast texture.
* Display color space setting available.
* Export marked photos by copying.

## Shortcut list

### In thumbnail list
|Key|Description|
|---|-----------|
|Alt + LeftClick|Toggle mark at the pointing photo|
|Shift + LeftClick|Select multiple photos from start to end to compare|
|Command/Ctrl + LeftClick|Pick multiple photos to compare|

### In photo area
|Key|Description|
|---|-----------|
|MouseWheel / Key, Key. / Key- Key= / Key_Q Key_E|Resize all photos|
|Command/Ctrl + Resize|Adjust all photos' EV|
|Alt + Resize|Adjust all photos' Gamma|
|Shift + **one of the above three**|Resize/adjust the pointing photo|
|Alt + LeftClick|Toggle mark at the pointing photo|
|Command/Ctrl + LeftClick|Toggle selection at the pointing photo|
|RightClick|View the pointing photo at fullscreen|
|1,2,3,4,5|Rate the pointing photo|

## Sample workflows
### Workflow 1 - rate raw photos
Rate your raw photos with the fast QuickRawPicker and then edit them in Bridge, Lightroom or Rawtherapee.

https://user-images.githubusercontent.com/403616/123539236-4855ff00-d76b-11eb-9c7e-583e490c62b4.mp4

> The rating operation is performed by pressing `3` on keyboard.

### Workflow 2 - mark raw photos and export
Mark your raw photos and then copy them to the folder desired.

https://user-images.githubusercontent.com/403616/123539349-e5189c80-d76b-11eb-94b2-c85aba85ee54.mp4

> The marking operation is performed by holding `alt` and clicking mouse left button.
