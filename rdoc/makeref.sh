#!/bin/bash
#
# Generate the ROOT reference manual for the specified version in the
# directory htmldoc or htmlv<root_major><root_minor>.
# This script is called with the following arguments:
#   makeref.sh master [ clean ]
#   makeref.sh <root_major>-<root_minor> [ clean ]
# e.g.:
#   makeref.sh master
#   makeref.sh 5-32 clean

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
   if [ -d $docdir/notes ]; then
      mv $docdir/notes notes-$gittag
   fi
   if [ -d $docdir/tutorials ]; then
      mv $docdir/tutorials tutorials-$gittag
   fi
   rm -rf $docdir
   mkdir $docdir
   if [ -d notes-$gittag ]; then
      mv notes-$gittag $docdir/
   fi
   if [ -d tutorials-$gittag ]; then
      mv tutorials-$gittag $docdir/
   fi
   exit 0
fi

# set ROOTSYS
. $srcdir/bin/thisroot.sh
echo "Using `which root` to generate the reference guide..."

Xvfb :0 -screen 0 1600x1200x24 > /dev/null 2>&1 &
export DISPLAY=:0

dir=`pwd`
cd $ROOTSYS/tutorials
# we need $ROOTSYS/tutorials/hsimple.root
if [ ! -f hsimple.root ]; then
   root -l -q hsimple.C
fi
cd tree
# we need $ROOTSYS/tutorials/tree/cernstaff.root
if [ ! -f cernstaff.root ]; then
   root -l -q cernbuild.C
fi
cd $dir

rm -f htmlref_C.*
#gdb --args root.exe -l -q htmlref.C+(\"$docdir\")
root -l -q "htmlref.C+(\"$docdir\")"
ret=$?

killall Xvfb
sleep 1  # in case next script starts Xvfb

exit $ret
