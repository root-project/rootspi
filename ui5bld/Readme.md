# Build script for openui5 package

Try to extract minimal possible set of openui5 libraries, used in ROOT

1. Download and unpack runtime tarball from openui5 website: https://openui5.org/download.html
   Tested with ui5 v1.63.0 - used in ROOT as on May 2019

2. Run provided shell script:

    [shell] ./build.sh /path/to/unpacked/openui5

3. Move created tarball into root sources `$ROOT_SOURCE_DIR/gui/webdisplay/res/` subfolder

4. Add entry with mid5 checksum into cmake/modules/SearchInstalledSoftware.cmake

    [shell] sha256sum openui5.tar.gz

5. Create PR
