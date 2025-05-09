#!/bin/bash

rm -rf resources *.txt

src=${1}
if [[ "$src" == "" ]]; then
   src=~/d/openui5-1.135.0/
fi

copy_lib() {
   echo "copy lib $1"
   mkdir -p ${1}
   cp ${src}/${1}/library.js ${1}
   cp ${src}/${1}/library-preload.js ${1}
   cp ${src}/${1}/library-preload.js.map ${1}
   cp ${src}/${1}/messagebundle.properties ${1}/messagebundle.properties
   cp ${src}/${1}/messagebundle_en.properties ${1}/messagebundle_en.properties
}

copy_themes() {
   echo "copy themes $1"
   mkdir -p ${1}/themes
   cp -r ${src}/${1}/themes/base ${1}/themes
   cp -r ${src}/${1}/themes/sap_fiori_3 ${1}/themes
   cp -r ${src}/${1}/themes/sap_fiori_3_dark ${1}/themes
   cp -r ${src}/${1}/themes/sap_horizon ${1}/themes
   cp -r ${src}/${1}/themes/sap_horizon_dark ${1}/themes
}

cp ${src}/*.txt .
mkdir resources
cp ${src}/resources/sap-ui-core.js resources/
cp ${src}/resources/sap-ui-core.js.map resources/

copy_lib resources/sap/ui/core
copy_themes resources/sap/ui/core
mkdir resources/sap/ui/core/cldr
cp ${src}/resources/sap/ui/core/cldr/en.json resources/sap/ui/core/cldr

# copy_lib resources/sap/ui/codeeditor

mkdir -p resources/sap/ui/codeeditor/
mkdir -p resources/sap/ui/codeeditor/js/ace/
mkdir -p resources/sap/ui/codeeditor/js/ace/snippets/
mkdir -p resources/sap/ui/codeeditor/js/ace/css/
cp ${src}/resources/sap/ui/codeeditor/library-preload.js resources/sap/ui/codeeditor/
cp ${src}/resources/sap/ui/codeeditor/library-preload.js.map resources/sap/ui/codeeditor/
cp ${src}/resources/sap/ui/codeeditor/js/ace/ace.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/ext-language_tools.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/ext-beautify.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-c_cpp.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-css.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-javascript.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-json.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-html.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-latex.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-markdown.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-plain_text.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-python.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-sh.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-fortran.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/mode-xml.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/worker-css.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/worker-html.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/worker-json.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/worker-javascript.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/worker-xml.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/theme-tomorrow.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/theme-github.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/theme-eclipse.js resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/javascript.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/plain_text.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/c_cpp.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/fortran.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/html.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/json.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/markdown.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/python.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/latex.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/css.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/sh.js resources/sap/ui/codeeditor/js/ace/snippets/
cp ${src}/resources/sap/ui/codeeditor/js/ace/snippets/xml.js resources/sap/ui/codeeditor/js/ace/snippets/
cp -r ${src}/resources/sap/ui/codeeditor/js/ace/css/ resources/sap/ui/codeeditor/js/ace/
cp ${src}/resources/sap/ui/codeeditor/messagebundle.properties resources/sap/ui/codeeditor/
cp ${src}/resources/sap/ui/codeeditor/messagebundle_en.properties resources/sap/ui/codeeditor/



copy_themes resources/sap/ui/codeeditor

copy_lib resources/sap/m
copy_themes resources/sap/m

copy_lib resources/sap/tnt
copy_themes resources/sap/tnt

copy_lib resources/sap/uxap
copy_themes resources/sap/uxap

copy_lib resources/sap/f
copy_themes resources/sap/f

copy_lib resources/sap/ui/layout
copy_themes resources/sap/ui/layout

copy_lib resources/sap/ui/table
copy_themes resources/sap/ui/table

copy_lib resources/sap/ui/unified
copy_themes resources/sap/ui/unified
mkdir -p resources/sap/ui/unified/img/ColorPicker
cp ${src}/resources/sap/ui/unified/img/ColorPicker/Alphaslider_BG.png resources/sap/ui/unified/img/ColorPicker

copy_lib resources/sap/ui/commons
copy_themes resources/sap/ui/commons

mkdir -p resources/sap/ui/unified/themes
cp -r ${src}/resources/sap/ui/unified/themes/base resources/sap/ui/unified/themes

mkdir -p resources/sap/ui/commons/themes
cp -r ${src}/resources/sap/ui/commons/themes/base resources/sap/ui/commons/themes

mkdir -p resources/sap/ui/thirdparty
cp ${src}/resources/sap/ui/thirdparty/jquery-compat.js resources/sap/ui/thirdparty

rm -f openui5.tar.gz

tar chf openui5.tar *.txt resources
gzip openui5.tar

echo ==== add checksum into cmake/modules/SearchInstalledSoftware.cmake ====
sha256sum openui5.tar.gz

rm -rf *.txt resources
