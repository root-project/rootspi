#!/bin/bash

rm -rf resources *.txt

src=${1}
if [[ "$src" == "" ]]; then
   src=/d/openui5/
fi

bndl0=messagebundle_en.properties
bndl=messagebundle_en_US.properties

copy_themes() {
   echo "copy themes for $1"
   mkdir -p ${1}/themes
   cp -r ${src}/${1}/themes/base ${1}/themes
   cp -r ${src}/${1}/themes/sap_belize ${1}/themes
   cp -r ${src}/${1}/themes/sap_fiori_3 ${1}/themes
}

cp ${src}/*.txt .
mkdir resources
cp ${src}/resources/sap-ui-core-nojQuery.js resources/
cp ${src}/resources/sap-ui-core-nojQuery.js.map resources/

mkdir -p resources/sap/ui/core/
cp ${src}/resources/sap/ui/core/library-preload.js resources/sap/ui/core/
cp ${src}/resources/sap/ui/core/library-preload.js.map resources/sap/ui/core/
cp ${src}/resources/sap/ui/core/${bndl0} resources/sap/ui/core/${bndl}

copy_themes resources/sap/ui/core

mkdir -p resources/sap/ui/codeeditor/
mkdir -p resources/sap/ui/codeeditor/js/ace/
mkdir -p resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/library-preload.js resources/sap/ui/codeeditor/
cp ${src}/resources/sap/ui/codeeditor/library-preload.js.map resources/sap/ui/codeeditor/
cp ${src}/resources/sap/ui/codeeditor/js/ace/ace.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/ext-language_tools.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/ext-beautify.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-javascript.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-json.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-c_cpp.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/theme-tomorrow.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/javascript.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/c_cpp.js resources/sap/ui/codeeditor/js/ace/snippets/

copy_themes resources/sap/ui/codeeditor

mkdir -p resources/sap/m/
cp ${src}/resources/sap/m/library-preload.js resources/sap/m/
cp ${src}/resources/sap/m/library-preload.js.map resources/sap/m/
cp ${src}/resources/sap/m/${bndl0} resources/sap/m/${bndl}
copy_themes resources/sap/m

mkdir -p resources/sap/uxap/
cp ${src}/resources/sap/uxap/library-preload.js resources/sap/uxap/
cp ${src}/resources/sap/uxap/library-preload.js.map resources/sap/uxap/
cp ${src}/resources/sap/uxap/${bndl0} resources/sap/uxap/${bndl}
copy_themes resources/sap/uxap

mkdir -p resources/sap/ui/layout/
cp ${src}/resources/sap/ui/layout/library-preload.js resources/sap/ui/layout/
cp ${src}/resources/sap/ui/layout/library-preload.js.map resources/sap/ui/layout/
cp ${src}/resources/sap/ui/layout/${bndl0} resources/sap/ui/layout/${bndl}
copy_themes resources/sap/ui/layout

mkdir -p resources/sap/ui/table/
cp ${src}/resources/sap/ui/table/library-preload.js resources/sap/ui/table/
cp ${src}/resources/sap/ui/table/library-preload.js.map resources/sap/ui/table/
cp ${src}/resources/sap/ui/table/${bndl0} resources/sap/ui/table/${bndl}
copy_themes resources/sap/ui/table

mkdir -p resources/sap/ui/unified/
cp ${src}/resources/sap/ui/unified/library-preload.js resources/sap/ui/unified/
cp ${src}/resources/sap/ui/unified/library-preload.js.map resources/sap/ui/unified/
cp ${src}/resources/sap/ui/unified/${bndl0} resources/sap/ui/unified/${bndl}
mkdir -p resources/sap/ui/unified/img/ColorPicker
cp ${src}/resources/sap/ui/unified/img/ColorPicker/Alphaslider_BG.png resources/sap/ui/unified/img/ColorPicker
copy_themes resources/sap/ui/unified

mkdir -p resources/sap/ui/commons/
cp ${src}/resources/sap/ui/commons/library-preload.js resources/sap/ui/commons/
cp ${src}/resources/sap/ui/commons/library-preload.js.map resources/sap/ui/commons/
cp ${src}/resources/sap/ui/commons/${bndl0} resources/sap/ui/commons/${bndl}
copy_themes resources/sap/ui/commons

mkdir -p resources/sap/ui/unified/themes
cp -r ${src}/resources/sap/ui/unified/themes/base resources/sap/ui/unified/themes

mkdir -p resources/sap/ui/commons/themes
cp -r ${src}/resources/sap/ui/commons/themes/base resources/sap/ui/commons/themes

rm -f openui5.tar.gz

tar chf openui5.tar *.txt resources
gzip openui5.tar

echo ==== add checksum into cmake/modules/SearchInstalledSoftware.cmake ====
sha256sum openui5.tar.gz

rm -rf *.txt resources
