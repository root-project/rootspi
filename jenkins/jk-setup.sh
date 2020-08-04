#!/bin/bash -x

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

THIS=$(dirname ${BASH_SOURCE[0]})

if [ $# -eq 1 ]; then
  LABEL=$1 ; shift
else
  echo "$0: expecting 1 argument [LABEL]"
  exit 1
fi

if command -v python >/dev/null 2>&1; then
    PYTHON=python
elif command -v python3 >/dev/null 2>&1; then
    PYTHON=python3
elif command -v python2 >/dev/null 2>&1; then
    PYTHON=python2
else
    echo "Cannot find python, python3, nor python2"
    exit 1
fi

PLATFORM=`$PYTHON $THIS/getPlatform.py`
ARCH=$(uname -m)

# Adjust enviroment PATH depending on the OS
if [[ $PLATFORM == *mac* ]]; then
  export PATH=/usr/local/bin:${PATH}
elif [[ $PLATFORM == *fedora* ]]; then
  export PATH=/usr/local/bin:${PATH}
fi

# Inject a modern git from cvmfs if reachable.
if [[ $(uname -s) == Linux ]]; then
  if [[ -e /cvmfs/sft.cern.ch/lcg/contrib/git/latest/$ARCH-slc6/bin ]]; then
    export PATH=/cvmfs/sft.cern.ch/lcg/contrib/git/latest/$ARCH-slc6/bin:$PATH
  fi
fi

# Use "ctest3" if it exists, otherwise ctest:
: ${CTEST:=$(command -v ctest3 >/dev/null && which ctest3 || which ctest)}

# Grab it from cvmfs on buildcoverity (SLC6):
if [[ $LABEL == *slc6* ]]; then
  CTEST=/cvmfs/sft.cern.ch/lcg/contrib/CMake/3.11.1/Linux-x86_64/bin/ctest
fi
export CTEST

if [[ $LABEL == *ubuntu1804-clangHEAD ]]; then
  # We use clang as a compiler with libstdc++.
  export PATH=/cvmfs/sft.cern.ch/lcg/contrib/llvm/latest/x86_64-ubuntu1804-gcc7-opt/bin/:$PATH
  export CC=`which clang`
  export CXX=`which clang++`
fi

if [[ $LABEL == *ubuntu2004-clang ]]; then
  export CC=`which clang`
  export CXX=`which clang++`
fi

if [[ $PLATFORM == *centos7* ]]; then
  export CCACHE_BASEDIR=$WORKSPACE
  export CCACHE_DIR=/ccache
  export CCACHE_MAXSIZE=10G
fi


# If run from Jenkins-----------------------------------------------------------------------
if [ x$WORKSPACE != x ]; then
  SCRATCH_DIR=$WORKSPACE/ipython
  export JUPYTER_CONFIG_DIR=$SCRATCH_DIR/.jupyter
  export JUPYTER_DATA_DIR=$SCRATCH_DIR/.local/share/jupyter
  export JUPYTER_PATH=$SCRATCH_DIR/.local/share/jupyter
  export JUPYTER_RUNTIME_DIR=$SCRATCH_DIR/.local/share/jupyter/runtime
  export IPYTHONDIR=$SCRATCH_DIR/.ipython
fi
