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
  return
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
else
  export EXTERNALDIR=$HOME/ROOT-externals
fi

# Setup all the externals now-----------------------------------------------------
PLATFORM=`$THIS/getPlatform.py`
COMPATIBLE=`$THIS/getCompatiblePlatform.py $PLATFORM`
if [ -a $EXTERNALDIR/$EXTERNALS/$PLATFORM ]; then
  source $EXTERNALDIR/$EXTERNALS/$PLATFORM/setup.sh
elif [ -a $EXTERNALDIR/$EXTERNALS/$COMPATIBLE ]; then
  source $EXTERNALDIR/$EXTERNALS/$COMPATIBLE/setup.sh
elif [[ $PLATFORM == *slc6* ]]; then
  export PATH=/afs/cern.ch/sw/lcg/contrib/CMake/3.2.3/Linux-$ARCH/bin:${PATH}
else
  echo "No externals for $PLATFORM in $EXTERNALDIR/$EXTERNALS"
fi

# The final compiler may not yet be totally setup-------------------------------------
if [[ $COMPILER == *gcc* ]]; then
  export ExtraCMakeOptions="-Dchirp=OFF -Dhdfs=OFF -Dbonjour=OFF ${ExtraCMakeOptions}"
  if [ $ARCH != i686 ]; then
    export ExtraCMakeOptions="-Dfail-on-missing=ON -Dbuiltin_lzma=ON ${ExtraCMakeOptions}"
  fi
  if [[ $COMPILER == *gcc6* ]]; then   # problems with Vc on GCC 6.X
    export ExtraCMakeOptions="-Dvc=OFF ${ExtraCMakeOptions}"
  fi
elif [[ $COMPILER == *clang* ]]; then
  clang34version=3.4
  clang35version=3.5
  clang36version=3.6
  COMPILERversion=${COMPILER}version
  clang34gcc=48
  clang35gcc=49
  clang36gcc=49
  GCCversion=${COMPILER}gcc
  . /afs/cern.ch/sw/lcg/external/llvm/${!COMPILERversion}/${ARCH}-slc6/setup.sh
  export CC=`which clang`
  export CXX=`which clang++`
  export ExtraCMakeOptions="${ExtraCMakeOptions} -Dfortran=OFF -Dgcctoolchain=$(dirname $(dirname `which gcc`))"
elif [[ $COMPILER == *native* ]]; then
  if [[ $LABEL == *mac* ]] ; then
    export FC=`which gfortran`
  else
    export ExtraCMakeOptions="-Dfortran=OFF ${ExtraCMakeOptions}"
  fi
elif [[ $COMPILER == *icc* ]]; then
  iccyear=2013
  icc14year=2013
  icc15year=2015
  COMPILERyear=${COMPILER}year
  iccgcc=4.8
  icc14gcc=4.8
  icc15gcc=4.9
  GCCversion=${COMPILER}gcc
  . /afs/cern.ch/sw/lcg/contrib/gcc/${!GCCversion}/${ARCH}-slc6/setup.sh
  . /afs/cern.ch/sw/IntelSoftware/linux/setup.sh
  . /afs/cern.ch/sw/IntelSoftware/linux/${ARCH}/xe${!COMPILERyear}/bin/ifortvars.sh intel64
  . /afs/cern.ch/sw/IntelSoftware/linux/${ARCH}/xe${!COMPILERyear}/bin/iccvars.sh intel64
  export CC=icc
  export CXX=icc
  export FC=ifort
  export ExtraCMakeOptions="${ExtraCMakeOptions} -Dvc=OFF"
fi

