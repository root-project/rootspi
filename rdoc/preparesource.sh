#!/bin/bash -e
#
# Get the ROOT source specified by the gittag passed as $1.

prog=`basename $0`
if [ $# -ne 1 ]; then
   echo "$prog: no git tag specified"
   exit 1
fi

gittag=$1

mkdir -p src
cd src

if [ -d $gittag ]; then
   cd $gittag
   git pull
   git reset --hard
   git checkout $gittag
   cd ..
else
   git clone -b $gittag http://root.cern.ch/git/root.git $gittag
fi

if [ ! -d $gittag.build ]; then
   mkdir -p $gittag.build 
fi

if [ -f $gittag/CMakeLists.txt ]; then
   cd $gittag.build
   cmake -G Ninja ../$gittag
   cmake --build .
   exit $?
else
   echo "$prog: $gittag/CMakeLists.txt not found, checkout of $gittag failed"
   exit 1
fi

exit 0
