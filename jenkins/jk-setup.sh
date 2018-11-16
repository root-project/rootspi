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

# Inject a modern CMake and git from cvmfs if they are reachable.
if [[ $(uname -s) == Linux ]]; then
  if [[ -e /cvmfs/sft.cern.ch/lcg/contrib/CMake/3.6.0/Linux-$ARCH/bin ]]; then
    export PATH=/cvmfs/sft.cern.ch/lcg/contrib/CMake/3.6.0/Linux-$ARCH/bin:${PATH}
  fi
  if [[ -e /cvmfs/sft.cern.ch/lcg/contrib/git/latest/$ARCH-slc6/bin ]]; then
    export PATH=/cvmfs/sft.cern.ch/lcg/contrib/git/latest/$ARCH-slc6/bin:$PATH
  fi
fi

if [[ $LABEL == *-clangHEAD ]]; then
  # We use clang as a compiler with libstdc++.
  # Get the gcc version. First parameter is a zero-based offset and the second is the length.
  . /afs/cern.ch/sw/lcg/contrib/gcc/6.2/x86_64-centos7/setup.sh
  export PATH=/cvmfs/sft.cern.ch/lcg/contrib/llvm/latest/x86_64-centos7-gcc62-opt/bin/:$PATH
  export CC=`which clang`
  export CXX=`which clang++`
  export ExtraCMakeOptions="${ExtraCMakeOptions} -Dfortran=OFF -Dhdfs=OFF"
  # On centos7 we want to compile with a more 'standard' toolchain.
  export ExtraCMakeOptions="${ExtraCMakeOptions} -Dgcctoolchain=$(dirname $(dirname `which gcc`))"
elif [[ $COMPILER == *native* ]]; then
  unset CC
  unset CXX
  unset FC
fi

if [[ $PLATFORM == *centos7* ]]; then
  # No ccache on centos7-manycore:
  if [[ "$LABEL" != "centos7-manycore" ]]; then
    export CCACHE_BASEDIR=/mnt/build/jenkins/workspace/
    export CCACHE_DIR=/ccache
    export CCACHE_MAXSIZE=10G
  fi
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
