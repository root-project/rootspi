#!/bin/bash

rm -rf resources *.txt

src=${1}
if [[ "$src" == "" ]]; then
   src=/d/openui5/
fi

bndl0=messagebundle_en.properties
bndl=messagebundle_en_US.properties
tdir=themes/sap_belize
themes=${tdir}/library.css
params=${tdir}/library-parameters.json

cp ${src}/*.txt .
mkdir resources
cp ${src}/resources/sap-ui-core-nojQuery.js resources/
cp ${src}/resources/sap-ui-core-nojQuery.js.map resources/

mkdir -p resources/sap/ui/core/
# mkdir -p resources/sap/ui/core/${tdir}
cp ${src}/resources/sap/ui/core/library-preload.js resources/sap/ui/core/
cp ${src}/resources/sap/ui/core/library-preload.js.map resources/sap/ui/core/
cp ${src}/resources/sap/ui/core/${bndl0} resources/sap/ui/core/${bndl}
# cp ${src}/resources/sap/ui/core/${themes} resources/sap/ui/core/${tdir}

mkdir -p resources/sap/ui/codeeditor/
mkdir -p resources/sap/ui/codeeditor/${tdir}
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

# cp ${src}/resources/sap/ui/codeeditor/${bndl0} resources/sap/ui/codeeditor/${bndl}
cp ${src}/resources/sap/ui/codeeditor/${themes} resources/sap/ui/codeeditor/${tdir}
cp ${src}/resources/sap/ui/codeeditor/${params} resources/sap/ui/codeeditor/${tdir}

mkdir -p resources/sap/m/
mkdir -p resources/sap/m/${tdir}
cp ${src}/resources/sap/m/library-preload.js resources/sap/m/
cp ${src}/resources/sap/m/library-preload.js.map resources/sap/m/
cp ${src}/resources/sap/m/${bndl0} resources/sap/m/${bndl}
cp ${src}/resources/sap/m/${themes} resources/sap/m/${tdir}
cp ${src}/resources/sap/m/${params} resources/sap/m/${tdir}

mkdir -p resources/sap/uxap/
mkdir -p resources/sap/uxap/${tdir}
cp ${src}/resources/sap/uxap/library-preload.js resources/sap/uxap/
cp ${src}/resources/sap/uxap/library-preload.js.map resources/sap/uxap/
cp ${src}/resources/sap/uxap/${bndl0} resources/sap/uxap/${bndl}
cp ${src}/resources/sap/uxap/${themes} resources/sap/uxap/${tdir}
cp ${src}/resources/sap/uxap/${params} resources/sap/uxap/${tdir}

mkdir -p resources/sap/ui/layout/
mkdir -p resources/sap/ui/layout/${tdir}
cp ${src}/resources/sap/ui/layout/library-preload.js resources/sap/ui/layout/
cp ${src}/resources/sap/ui/layout/library-preload.js.map resources/sap/ui/layout/
cp ${src}/resources/sap/ui/layout/${bndl0} resources/sap/ui/layout/${bndl}
cp ${src}/resources/sap/ui/layout/${themes} resources/sap/ui/layout/${tdir}
cp ${src}/resources/sap/ui/layout/${params} resources/sap/ui/layout/${tdir}

mkdir -p resources/sap/ui/table/
mkdir -p resources/sap/ui/table/${tdir}
cp ${src}/resources/sap/ui/table/library-preload.js resources/sap/ui/table/
cp ${src}/resources/sap/ui/table/library-preload.js.map resources/sap/ui/table/
cp ${src}/resources/sap/ui/table/${bndl0} resources/sap/ui/table/${bndl}
cp ${src}/resources/sap/ui/table/${themes} resources/sap/ui/table/${tdir}
cp ${src}/resources/sap/ui/table/${params} resources/sap/ui/table/${tdir}

mkdir -p resources/sap/ui/unified/
mkdir -p resources/sap/ui/unified/${tdir}
mkdir -p resources/sap/ui/unified/img/ColorPicker
cp ${src}/resources/sap/ui/unified/library-preload.js resources/sap/ui/unified/
cp ${src}/resources/sap/ui/unified/library-preload.js.map resources/sap/ui/unified/
cp ${src}/resources/sap/ui/unified/${bndl0} resources/sap/ui/unified/${bndl}
cp ${src}/resources/sap/ui/unified/${themes} resources/sap/ui/unified/${tdir}
cp ${src}/resources/sap/ui/unified/${params} resources/sap/ui/unified/${tdir}
cp ${src}/resources/sap/ui/unified/img/ColorPicker/Alphaslider_BG.png resources/sap/ui/unified/img/ColorPicker

mkdir -p resources/sap/ui/commons/
mkdir -p resources/sap/ui/commons/${tdir}
cp ${src}/resources/sap/ui/commons/library-preload.js resources/sap/ui/commons/
cp ${src}/resources/sap/ui/commons/library-preload.js.map resources/sap/ui/commons/
cp ${src}/resources/sap/ui/commons/${bndl0} resources/sap/ui/commons/${bndl}
cp ${src}/resources/sap/ui/commons/${themes} resources/sap/ui/commons/${tdir}
cp ${src}/resources/sap/ui/commons/${params} resources/sap/ui/commons/${tdir}

mkdir -p resources/sap/ui/core/themes
cp -r ${src}/resources/sap/ui/core/themes/base resources/sap/ui/core/themes
cp -r ${src}/resources/sap/ui/core/themes/sap_belize resources/sap/ui/core/themes

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
