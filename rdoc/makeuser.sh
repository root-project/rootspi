#!/bin/bash
#
# Make the User's Guide and copy to the htmldoc directory:
# htmldoc/users-guide/.
# This script is called with the following arguments:
#   makeuser.sh master [ clean ]
#   makeuser.sh <root_major>-<root_minor> [ clean ]
# e.g.:
#   makeuser.sh master
#   makeuser.sh 5-34 clean

prog=`basename $0`
if [ $# -ge 1 ]; then
   vers="$1"
   if [ "x$1" = "xmaster" ]; then
      major=
      docdir="htmldoc/users-guide"
      gittag="master"
      versnum=`ls src/master/doc | tail -1`
   else
      major=`echo $1 | cut -d- -f 1`
      minor=`echo $1 | cut -d- -f 2`
      docdir="html$major$minor/users-guide"
      gittag="v$major-$minor-00-patches"
      versnum="v$major$minor"
   fi
   srcdir="src/$gittag"
else
   echo "$prog: no version arguments specified"
   exit 1
fi

if [ "x$2" = "xclean" ]; then
   echo "removing $docdir"
   rm -rf $docdir
   exit 0
fi

echo "$prog: using version number $gittag"

if [ ! -d $docdir ]; then
   mkdir -p $docdir
fi

# Make User's Guide
dir=`pwd`
cd $srcdir/documentation/users-guide
make
cd $dir
./copyug.sh $srcdir/documentation/users-guide $docdir

exit 0
