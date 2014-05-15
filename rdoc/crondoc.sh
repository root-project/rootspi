#!/bin/bash
#

# to set the LD_LIBRARY_PATH needed by some ROOT plugins
. /user/rdm/.bash_profile

cd /user/rdm/rootspi/rdoc
./makedoc.sh master > makedoc-master.log 2>& 1
./makedoc.sh 5-34 > makedoc-5-34.log 2>& 1
