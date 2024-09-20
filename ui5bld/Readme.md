# Build script for openui5 package

Try to extract minimal possible set of openui5 libraries, used in ROOT

1. Download and unpack runtime tarball from openui5 website: https://openui5.org/releases
   Currently working with ui5 v1.128.0 - used in ROOT as in September 2024

2. Run provided shell script:

    [shell] ./build.sh /path/to/unpacked/openui5

3. Move created tarball into root sources `$ROOT_SOURCE_DIR/builtins/openui5/` subfolder

4. Add entry with mid5 checksum into cmake/modules/SearchInstalledSoftware.cmake

    [shell] sha256sum openui5.tar.gz

5. Create PR
