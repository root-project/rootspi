#!/bin/bash -ex
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
      gittag="master"
      docdir="master"
   else
      major=`echo $1 | cut -d- -f 1`
      minor=`echo $1 | cut -d- -f 2`
      gittag="v$major-$minor-00-patches"
      if [ "$major" = "5" -o "$vers" = "6-02" -o "$vers" = "6-04" -o "$vers" = "6-06" ]; then
         docdir="html$major$minor"
      else
         docdir="v$major$minor"
      fi
   fi
   srcdir="src/$gittag"
   builddir="src/$gittag.build"
else
   echo "$prog: no version arguments specified"
   exit 1
fi

# set ROOTSYS
dir=`pwd`
. $builddir/bin/thisroot.sh
echo "Using `which root` to generate the doxygen guide..."

# clean up previous files: removed types etc.
rm -rf $docdir $dir/${docdir}_TMP

# set HOME (used by doxygen/Makefile)
export DOXYGEN_OUTPUT_DIRECTORY=$dir/${docdir}_TMP

# make doxygen
if [ -d $srcdir/documentation/doxygen ]; then
  cd $srcdir/documentation/doxygen
  make
  cd $dir
  mv $dir/${docdir}_TMP/html $dir/${docdir}
  if [ -d $dir/${docdir}_TMP/notebooks ]; then
    mv $dir/${docdir}_TMP/notebooks $dir/${docdir}/notebooks
  fi
else
  echo "$prog: no doxygen documentation for this version"
fi


