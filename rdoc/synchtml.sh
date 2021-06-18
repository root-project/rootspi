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
   tarnamexz1=${docdir/v/html}.tar
   tar cf $tarnamexz1 $docdir
   xz -T5 -f $tarnamexz1
   tarnamexz2=${docdir/v/html}.tar.xz
   scp $tarnamexz2 root.cern.ch:/var/www/root/download/
fi

exit $ret
