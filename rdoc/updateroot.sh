#!/bin/bash
#
# Update the binary ROOT version to be used for generating the doc.

cd $ROOTSYS
git pull
./ALLCONFIG.sh
make -j 4

ret=$?

exit $ret
