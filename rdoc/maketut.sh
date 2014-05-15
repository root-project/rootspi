#!/bin/bash
#
# Generate the ROOT hyperized tutorials for the specified version in the
# directory htmldoc or htmlv<root_major><root_minor>.
# This script is called with the following arguments:
#   maketut.sh master [ clean ]
#   maketut.sh <root_major>-<root_minor> [ clean ]
# e.g.:
#   maketut.sh master
#   maketut.sh 5-32 clean

prog=`basename $0`
if [ $# -ge 1 ]; then
   vers="$1"
   if [ "x$1" = "xmaster" ]; then
      major=
      docdir="htmldoc"
      gittag="master"
   else
      major=`echo $1 | cut -d- -f 1`
      minor=`echo $1 | cut -d- -f 2`
      docdir="html$major$minor"
      gittag="v$major-$minor-00-patches"
   fi
   srcdir="src/$gittag"
else
   echo "$prog: no version arguments specified"
   exit 1
fi

if [ "x$2" = "xclean" ]; then
   echo "removing $docdir/tutorials"
   rm -rf $docdir/tutorials
   exit 0
fi

# set ROOTSYS
. $srcdir/bin/thisroot.sh
echo "Using `which root` to generate the tutorials..."

dir=`pwd`
cd $ROOTSYS/test
unset ROOTBUILD
# we need $ROOTSYS/test/libEvent.so
if [ ! -f libEvent.so ]; then
   make Event
fi
cd $dir

Xvfb :0 -screen 0 1600x1200x24 > /dev/null 2>&1 &
export DISPLAY=:0

rm -f htmltut_C.*
root -l -q "htmltut.C+(\"$docdir\")"
ret=$?

killall Xvfb
sleep 1  # in case next script starts Xvfb

exit $ret
