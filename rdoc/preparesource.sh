#!/bin/bash -e
#
# Get the ROOT source specified by the gittag passed as $1.

prog=`basename $0`
if [ $# -lt 1 ]; then
   echo "$prog: no git tag specified"
   exit 1
fi

gittag=$1
shift
gitcommit=$1
if [ x"$gitcommit" = "x" ]; then
  gitcommit=$gittag
fi

mkdir -p src
cd src

if [ -d $gittag ]; then
   cd $gittag
   git pull
   git reset --hard
   git checkout $gitcommit
else
   git clone -b $gittag http://root.cern.ch/git/root.git $gittag
   cd $gittag
   git checkout $gitcommit
fi

if [ -x configure ]; then
   # update config script
   cp ../../ALLCONFIG.sh .
   ./ALLCONFIG.sh
   make -j 4
   exit $?
else
   echo "$prog: ./configure not found, checkout of $gittag failed"
   exit 1
fi

exit 0
