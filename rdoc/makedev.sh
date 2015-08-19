#!/bin/bash -x
#
# Hyperize the dev notes (ChangeLog) for the specified version in the
# file htmldoc/notes/dev-notes.html.
# This script is called with the following arguments:
#   makedev.sh master [ clean ]
#   makedev.sh <root_major>-<root_minor> [ clean ]
# e.g.:
#   makedev.sh master
#   makedev.sh 5-32 clean

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
   echo "removing $docdir/dev-notes.html"
   rm -f $docdir/dev-notes.html
   exit 0
fi

echo "$prog: using version number $gittag"

# Make ChangeLog file
dir=`pwd`
cd $srcdir
make changelog
mv README/ChangeLog $dir/ChangeLog-$gittag
cd $dir

# set ROOTSYS
. $srcdir/bin/thisroot.sh
echo "Using `which root` to generate the development notes..."

# start framebuffer X11 server
Xvfb :0 -screen 0 1600x1200x24 > /dev/null 2>&1 &
export DISPLAY=:0

root -l -q "htmldev.C(\"ChangeLog-$gittag\", \"$docdir\", \"$versnum\")"
ret=$?

killall Xvfb
sleep 1  # in case next script starts Xvfb

rm -f dev-notes-$versnum.txt
mv $docdir/dev-notes-$versnum.txt.html $docdir/dev-notes.html

exit $ret
