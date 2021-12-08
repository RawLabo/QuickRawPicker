# Settings 

### General tab

|Item|Description|
|----|-----------|
|Display bit|16 bits is recommended. This describes how image is parsed from RAW file. 16 bits will consume more video memory but can usually cover all the 12/14/16 bits data from RAW file.|
|Loading thumbnail|Display a scaled thumbnail if true. Display black loading screen if false.|
|Zoom at AF point|When zooming to 100% from the shrinked size, it can automatically zoom to the AotuFocus point if it exists. Otherwise, it will zoom to the cursor position.|
|Cache round|Rounds to cache the previously opened images.|
|Color space|Display color space for images. This won't affect the thumbnail list part which always displays in SRGB.|
|Export associated|This sets the associated file rules in exporting. <br> The delimiter must be `/`<br>`$` means the raw file name without the extension(Like `DSC00032`)<br>`#` means the raw file name.(Like `DSC00032.ARW`)<br>For example:<br>`$.JPG` means also copy a file named `DSC00032.JPG`<br>`#.xmp` means also copy a file named `DSC00032.ARW.xmp`<br>`$.xmp` means also copy a file named `DSC00032.xmp`<br>Example: `$.JPG/#.xmp` <- this means it'll also copy the JPG file and the darktable generated xmp file.|
|UI Scale|This can sacle the whole UI for fit some HD display environments.|
|Threads|Set the thread number to use.|

### Render tab
|Item|Description|
|----|-----------|
|Renderer|For most cases, GLES3 is the best choice. However, if your graphics card is too old, you have black screens when opening photos or performance problems when opening too many photos at the same time, you can still choose to use GLES2.|
|Shadow Threshold|This is the upper limit of the shadow clipping shader.|
|Highlight Threshold|This is the upper limit of the highlight clipping shader.|
|One channel|When it is enabled, either red, green or blue above the highlight threshold will activate the highlight shader. When it is disabled, it requires all three channels to be above the highlight threshold.|
|Default EV|The default exposure value of a parsed photo.|
|Default Gamma|The default gamma value of a parsed photo.|

### Rating tab
|Rating type|Decide which type of sidecar file should be read and write.|
|XMP template|The custom template is used when creating the XMP sidecar file.|
|PP3 template|The custom template is used when creating the PP3 sidecar file.|
