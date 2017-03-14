#!/bin/bash -e
#
# Generate ROOT HTML documentation:
#   makedoc.sh master [ clean ]
#   makedoc.sh <root_major>-<root_minor> [ clean ]
# e.g.:
#   makedoc.sh master
#   makedoc.sh 5-32 clean

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

# update ROOT executable
#./updateroot.sh
#if [ $? -ne 0 ]; then
#   echo "$prog: ROOT update and compilation failed, exiting..."
#   exit 1
#fi

# Checkout and build the source for which to generate the doc
 ./preparesource.sh $gittag
if [ $? -ne 0 ]; then
   echo "$prog: preparesource.sh failed, exiting..."
   exit 1
fi

./makedoxy.sh $vers
if [ $? -ne 0 ]; then
   echo "$prog: makedoxy.sh failed, exiting..."
   exit 1
fi

#./maketut.sh $vers
#if [ $? -ne 0 ]; then
#   echo "$prog: maketut.sh failed, exiting..."
#   exit 1
#fi

./synchtml.sh $docdir
if [ $? -ne 0 ]; then
   echo "$prog: synchtml.sh failed, exiting..."
   exit 1
fi

. ../ROOT-Primer/scripts/build.sh root.cern.ch:/var/www/root/root/htmldoc/guides/nbprimer all
if [ $? -ne 0 ]; then
   echo "$prog: Primer failed, exiting..."
   exit 1
fi


exit 0
