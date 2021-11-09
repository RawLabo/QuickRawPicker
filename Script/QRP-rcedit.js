// This is related to the "Windows Desktop" section in export_presets.cfg

const rcedit = require('rcedit')
rcedit("GUI/Build/win/QuickRawPicker-v0.2.1-win-x64.exe", {
  "icon": "GUI/Asset/Texture/icon.ico",
  "version-string": {
    CompanyName: "qdwang",
    ProductName: "QuickRawPicker",
    FileDescription: "QuickRawPicker",
    LegalCopyright: "qdwang",
    LegalTrademarks: "QuickRawPicker"
  },
  "file-version": "0.2.1.0",
  "product-version": "0.2.1.0"
})