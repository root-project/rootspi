#!/bin/bash
#
# Make the different guides and copy to them to the htmldoc directory:
# htmldoc/guides/.
# This script is called with the following arguments:
#   makeguides.sh master [ clean ]
#   makeguides.sh <root_major>-<root_minor> [ clean ]
# e.g.:
#   makeguides.sh master
#   makeguides.sh 5-34 clean

prog=`basename $0`
if [ $# -ge 1 ]; then
   vers="$1"
   if [ "x$1" = "xmaster" ]; then
      major=
      docdir="htmldoc/guides"
      gittag="master"
      versnum=`ls src/master/doc | tail -1`
   else
      major=`echo $1 | cut -d- -f 1`
      minor=`echo $1 | cut -d- -f 2`
      docdir="html$major$minor/guides"
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

# make Minuit2 guide
cd $srcdir/documentation/minuit2
make
cd $dir

# make ROOT primer
cd $srcdir/documentation/primer
make
cd $dir

# make Spectrum guide
cd $srcdir/documentation/spectrum
make
cd $dir

# make HttpServer guide
cd $srcdir/documentation/HttpServer
make
cd $dir

# copy different guides
./copyguides.sh $srcdir $docdir

exit 0
