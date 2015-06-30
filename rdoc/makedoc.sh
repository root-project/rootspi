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
# THtml cannot create documentation anymore since the move to doxygen syntax.
# So instead, make sure that we use a commit before - freezing the documentation.
$sourcetag = $gittag
if [ $gittag = "master" ]; then
   sourcetag="82a65d347e084d5bcaf329c5f09c7f93d73f044d"
elif [ $gittag = "v6-02-00-patches" ]; then
   sourcetag="5edaf3edc06f45150f9d7b822ff00c87b317ff02"
fi

./preparesource.sh $sourcetag
if [ $? -ne 0 ]; then
   echo "$prog: preparesource.sh failed, exiting..."
   exit 1
fi

# rename the directory
if [ $sourcetag != $gittag ]; then
   mv $sourcetag $gittag
fi

# Release notes (from the doc directories)
./makenotes.sh $vers
if [ $? -ne 0 ]; then
   echo "$prog: makenotes.sh failed, exiting..."
   exit 1
fi

# Changelog from Git (hyperized by THTML)
./makedev.sh $vers
if [ $? -ne 0 ]; then
   echo "$prog: makedev.sh failed, exiting..."
   exit 1
fi

./makeref.sh $vers
if [ $? -ne 0 ]; then
   echo "$prog: makeref.sh failed, exiting..."
   exit 1
fi

./makedoxy.sh $vers
if [ $? -ne 0 ]; then
   echo "$prog: makedoxy.sh failed, exiting..."
   exit 1
fi

./makeguides.sh $vers
if [ $? -ne 0 ]; then
   echo "$prog: makeguides.sh failed, exiting..."
   exit 1
fi

./maketut.sh $vers
if [ $? -ne 0 ]; then
   echo "$prog: maketut.sh failed, exiting..."
   exit 1
fi

./cpgifs.sh $docdir
if [ $? -ne 0 ]; then
   echo "$prog: cpgifs.sh failed, exiting..."
   exit 1
fi

./synchtml.sh $docdir
if [ $? -ne 0 ]; then
   echo "$prog: synchtml.sh failed, exiting..."
   exit 1
fi

exit 0
