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

PLATFORM=`$THIS/getPlatform.py`
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

if [[ $LABEL == *centos7-clangHEAD ]]; then
  # We use clang as a compiler with libstdc++.
  # Get the gcc version. First parameter is a zero-based offset and the second is the length.
  #. /cvmfs/sft.cern.ch/lcg/contrib/gcc/7.3.0/x86_64-centos7-gcc7-opt/setup.sh
  export PATH=/cvmfs/sft.cern.ch/lcg/contrib/llvm/latest/x86_64-centos7-gcc48-opt/bin/:$PATH
  export CC=`which clang`
  export CXX=`which clang++`
  # On centos7 + gcc52/gcc62 we want to compile with a more 'standard' toolchain.
  #export ExtraCMakeOptions="${ExtraCMakeOptions} -Dgcctoolchain=$(dirname $(dirname `which gcc`))"
fi

if [[ $LABEL == *ubuntu1804-clangHEAD ]]; then
  # We use clang as a compiler with libstdc++.
  export PATH=/cvmfs/sft.cern.ch/lcg/contrib/llvm/latest/x86_64-ubuntu1804-gcc7-opt/bin/:$PATH
  export CC=`which clang`
  export CXX=`which clang++`
fi

# Special settings for Clang HEAD and for ROOT-patched LLVM/Clang builds
# Label ROOT-cc7-gcc62 is also used for rootbench.git build
if [[ $LABEL == *-centos7-gcc62 ]]; then
  . /cvmfs/sft.cern.ch/lcg/contrib/gcc/6.2/x86_64-centos7/setup.sh
  export CC=`which gcc`
  export CXX=`which c++`
fi

if [[ $PLATFORM == *centos7* ]]; then
  export CCACHE_BASEDIR=/mnt/build/jenkins/workspace/
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
