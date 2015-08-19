#!/bin/bash -e
#
# Generate the ROOT Doxygen reference manual for the specified version in the
# directory rootdoc or root<root_major><root_minor>.
# This script is called with the following arguments:
#   makedoxy.sh master [ clean ]
#   makedoxy.sh <root_major>-<root_minor> [ clean ]
# e.g.:
#   makedoxy.sh master
#   makedoxy.sh 5-32 clean

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
   if [ -d $docdir/rootdoc ]; then
      rm -rf $docdir/rootdoc
   fi
   exit 0
fi

# set ROOTSYS
dir=`pwd`
. $srcdir/bin/thisroot.sh
echo "Using `which root` to generate the doxygen guide..."

# set HOME (used by doxygen/Makefile)
export HOME=$dir/$docdir

# make doxygen
if [ -d $srcdir/documentation/doxygen ]; then
  cd $srcdir/documentation/doxygen
  make
  cd $dir
else
  echo "$prog: no doxygen documentation for this version"
fi


