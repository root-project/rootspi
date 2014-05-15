#!/bin/bash
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

rsync -a $docdir/ /user/httpd/root/root/$docdir
ret=$?

tar zcf /user/ftp/root/${docdir}.tar.gz $docdir

exit $ret
