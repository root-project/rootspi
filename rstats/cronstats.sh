#!/bin/sh
#
export ROOTSYS=/user/rdm/root
export PATH=$ROOTSYS/bin:$PATH
export LD_LIBRARY_PATH=$ROOTSYS/lib:$LD_LIBRARY_PATH

cd /user/rdm/rootspi/rstats
./makestats.sh > makestats.log 2>& 1
