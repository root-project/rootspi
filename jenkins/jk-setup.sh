#!/bin/bash -x

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

THIS=$(dirname ${BASH_SOURCE[0]})

# first arguments is the source directory
if [ $# -ge 4 ]; then
  LABEL=$1 ; shift
  COMPILER=$1 ; shift
  BUILDTYPE=$1 ; shift
  EXTERNALS=$1 ; shift
else
  echo "$0: expecting 4 arguments [LABEL]  [COMPILER] [BUILDTYPE] [EXTERNALS]"
  exit 1
fi

export BUILDTYPE
export COMPILER

PLATFORM=`$THIS/getPlatform.py`
ARCH=$(uname -m)

if [[ $PLATFORM == *slc6* ]]; then
  LABEL=slc6
  export EXTERNALDIR=/afs/cern.ch/sw/lcg/app/releases/ROOT-externals
elif [[ $PLATFORM == *centos7* ]]; then
  LABEL=centos7
  export EXTERNALDIR=/afs/cern.ch/sw/lcg/app/releases/ROOT-externals
elif [[ $PLATFORM == *mac* ]]; then
  export PATH=/usr/local/bin:${PATH}
  export EXTERNALDIR=$HOME/ROOT-externals
elif [[ $PLATFORM == *fedora* ]]; then
  export PATH=/usr/local/bin:${PATH}
  export EXTERNALDIR=$HOME/ROOT-externals
else
  export EXTERNALDIR=$HOME/ROOT-externals
fi

# Setup all the externals now-----------------------------------------------------
PLATFORM=`$THIS/getPlatform.py`
COMPATIBLE=`$THIS/getCompatiblePlatform.py $PLATFORM`
if [ -a /cvmfs/sft.cern.ch/lcg/views/$EXTERNALS/$PLATFORM ]; then
  source /cvmfs/sft.cern.ch/lcg/views/$EXTERNALS/$PLATFORM/setup.sh
elif [ -a /cvmfs/sft.cern.ch/lcg/views/$EXTERNALS/$COMPATIBLE ]; then
  source /cvmfs/sft.cern.ch/lcg/views/$EXTERNALS/$COMPATIBLE/setup.sh
elif [ -a $EXTERNALDIR/$EXTERNALS/$PLATFORM ]; then
  source $EXTERNALDIR/$EXTERNALS/$PLATFORM/setup.sh
elif [ -a $EXTERNALDIR/$EXTERNALS/$COMPATIBLE ]; then
  source $EXTERNALDIR/$EXTERNALS/$COMPATIBLE/setup.sh
elif [[ $PLATFORM == *slc6* ]]; then
  export PATH=/afs/cern.ch/sw/lcg/contrib/CMake/3.6.0/Linux-$ARCH/bin:${PATH}
elif [[ $PLATFORM == *centos7* ]]; then
  export PATH=/afs/cern.ch/sw/lcg/contrib/CMake/3.6.0/Linux-$ARCH/bin:${PATH}
else
  echo "No externals for $PLATFORM in $EXTERNALDIR/$EXTERNALS"
fi

# The final compiler may not yet be totally setup-------------------------------------
if [[ $COMPILER == gcc* ]]; then
  export ExtraCMakeOptions="-Dchirp=OFF -Dhdfs=OFF -Dbonjour=OFF ${ExtraCMakeOptions}"
  if [ $ARCH != i686 ]; then
    export ExtraCMakeOptions="-Dfail-on-missing=ON -Dbuiltin_lzma=ON ${ExtraCMakeOptions}"
  fi
  if [[ $COMPILER == *gcc6* ]]; then   # problems with Vc on GCC 6.X
    export ExtraCMakeOptions="-Dvc=OFF ${ExtraCMakeOptions}"
  fi
  if [[ $COMPILER == *gcc7* ]]; then   # missing xrootd for the time being
    export ExtraCMakeOptions="-Dvc=OFF ${ExtraCMakeOptions}"
  fi

elif [[ $COMPILER == *clang* ]]; then
  clang34version=3.4
  clang35version=3.5
  clang36version=3.6
  clang39version=3.9
  COMPILERversion=${COMPILER}version
  clang34gcc=4.8
  clang35gcc=4.9
  clang36gcc=4.9
  clang39gcc=4.9
  GCCversion=${COMPILER}gcc
  if [[ $COMPILERversion == clang_gcc* ]]; then
    # We are cross compiling. We use clang as a compiler with libstdc++.
    # Get the gcc version. First parameter is a zero-based offset and the second is the length.
    GCCcompiler=${COMPILER:6:5}
    GCCversion=${COMPILER:9:2}
    GCCversion="${GCCversion:0:1}.${GCCversion:1:1}"
    . /cvmfs/sft.cern.ch/lcg/contrib/gcc/${GCCversion}/${ARCH}-${LABEL}/setup.sh
    export PATH=/cvmfs/sft.cern.ch/lcg/contrib/llvm/latest/${PLATFORM}/bin/:$PATH
  else
    . /cvmfs/sft.cern.ch/lcg/contrib/llvm/${!COMPILERversion}/${COMPATIBLE}/setup.sh
  fi

  export CC=`which clang`
  export CXX=`which clang++`
  export ExtraCMakeOptions="${ExtraCMakeOptions} -Dfortran=OFF"

  # On slc we want to compile with a more 'standard' toolchain.
  if [[ $PLATFORM == *slc* ]]; then
    export ExtraCMakeOptions="${ExtraCMakeOptions} -Dgcctoolchain=$(dirname $(dirname `which gcc`))"
  fi
elif [[ $COMPILER == *native* ]]; then
  unset CC
  unset CXX
  unset FC
  if [[ $LABEL == *mac* ]] ; then
#    export FC=`which gfortran`
#    export CC=`which clang`
#    export CXX=`which clang++`
    export ExtraCMakeOptions="-Dmacos_native=ON -Doracle=OFF ${ExtraCMakeOptions}"
  else
    export ExtraCMakeOptions="-Dfortran=OFF ${ExtraCMakeOptions}"
  fi
elif [[ $COMPILER == *icc* ]]; then
  iccyear=2013
  icc14year=2013
  icc15year=2015
  icc16year=2016
  COMPILERyear=${COMPILER}year
  iccgcc=4.8
  icc14gcc=4.8
  icc15gcc=4.9
  icc16gcc=4.9
  GCCversion=${COMPILER}gcc
  if [ $COMPILER == icc17 ]; then
      . /cvmfs/projects.cern.ch/intelsw/psxe/linux/all-setup.sh
  else
      . /afs/cern.ch/sw/lcg/contrib/gcc/${!GCCversion}/${ARCH}-slc6/setup.sh
      . /afs/cern.ch/sw/IntelSoftware/linux/setup.sh
      . /afs/cern.ch/sw/IntelSoftware/linux/${ARCH}/xe${!COMPILERyear}/bin/ifortvars.sh intel64
      . /afs/cern.ch/sw/IntelSoftware/linux/${ARCH}/xe${!COMPILERyear}/bin/iccvars.sh intel64
  fi
  export CC=`which icc`
  export CXX=`which icc`
  export FC=`which ifort`
  export ExtraCMakeOptions="${ExtraCMakeOptions} -Dvc=OFF"
fi

if [[ $LABEL == slc6 || $LABEL == centos7 ]]; then
    CCACHE_BASEDIR=/mnt/build/jenkins/workspace/
    CCACHE_DIR=/mnt/build/jenkins/workspace/
    CCACHE_MAXSIZE=10G
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
