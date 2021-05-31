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

if [ "$docdir" != "${docdir/html/}" ]; then
  rsync --delete -a $docdir/ root.cern.ch:/var/www/root/root/$docdir
  ret=$?
else
  rsync --delete --exclude release-notes.html -a $docdir/ root.cern.ch:/var/www/root/doc/$docdir
  ret=$?
fi

if [ $docdir != "master" -a $docdir != "html602" ]; then
   tarnamegz=${docdir/v/html}.tar.gz
   tar zcf $tarnamegz $docdir
   scp $tarnamegz root.cern.ch:/var/www/root/download/
   tarnamexz=${docdir/v/html}.tar
   tar cf $tarnamexz $docdir
   xz -T5 $tarnamexz
   scp $tarnamexz root.cern.ch:/var/www/root/download/
fi

exit $ret
