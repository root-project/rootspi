#!/bin/bash -x
#
# Make the release notes and copy to the htmldoc directory:
# htmldoc/notes/release-notes.html.
# This script is called with the following arguments:
#   makenotes.sh master [ clean ]
#   makenotes.sh <root_major>-<root_minor> [ clean ]
# e.g.:
#   makenotes.sh master
#   makenotes.sh 5-32 clean

prog=`basename $0`
if [ $# -ge 1 ]; then
   vers="$1"
   if [ "x$1" = "xmaster" ]; then
      major=
      docdir="htmldoc/notes"
      gittag="master"
      versnum=`ls src/master/doc | tail -1`
   else
      major=`echo $1 | cut -d- -f 1`
      minor=`echo $1 | cut -d- -f 2`
      docdir="html$major$minor/notes"
      gittag="v$major-$minor-00-patches"
      versnum="v$major$minor"
   fi
   srcdir="src/$gittag"
else
   echo "$prog: no version arguments specified"
   exit 1
fi

if [ "x$2" = "xclean" ]; then
   echo "removing $docdir/release-notes.html"
   rm -f $docdir/release-notes.html
   exit 0
fi

echo "$prog: using version number $gittag"

if [ ! -d $docdir ]; then
   mkdir -p $docdir
fi

# Make release notes
dir=`pwd`
cd $srcdir
make releasenotes
cd $dir
rm -f $srcdir/README/ReleaseNotes/$versnum/index.md
cp $srcdir/README/ReleaseNotes/$versnum/* $docdir/
mv $docdir/index.html $docdir/release-notes.html

exit 0
