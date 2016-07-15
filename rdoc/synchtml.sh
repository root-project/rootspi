#!/bin/bash -e
#
# Sync the generated doc tree.
# To be called like:
#   synchtml.sh html530

prog=`basename $0`
if [ $# -ne 1 ]; then
   echo "$prog: no docdir argument specified"
   exit 1
else
   docdir="$1"
fi

if [ "$docdir" = "master" ]; then
  rsync -a $docdir/ root.cern.ch:/var/www/root/doc/$docdir
  ret=$?
else
  rsync -a $docdir/ root.cern.ch:/var/www/root/root/$docdir
  ret=$?
fi

if [ $docdir != "master" -a $docdir != "html602" ]; then
   tar zcf ${docdir}.tar.gz $docdir
   scp ${docdir}.tar.gz root.cern.ch:/var/www/root/download/
fi

exit $ret
