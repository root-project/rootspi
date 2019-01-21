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

PLATFORM=`$THIS/../getPlatform.py`
ARCH=$(uname -m)

# Adjust LABEL and enviroment PATH depending on the OS
if [[ $PLATFORM == *slc6* ]]; then
  LABEL=slc6
elif [[ $PLATFORM == *centos7* ]]; then
  LABEL=centos7
elif [[ $PLATFORM == *mac* ]]; then
  export PATH=/usr/local/bin:${PATH}
elif [[ $PLATFORM == *fedora* ]]; then
  export PATH=/usr/local/bin:${PATH}
fi

# Setup all the externals now-----------------------------------------------------
PLATFORM=`$THIS/../getPlatform.py`
COMPATIBLE=`$THIS/../getCompatiblePlatform.py $PLATFORM`

if [[ $COMPILER == gcc73 ]]; then
  PLATFORM=${PLATFORM/gcc73/gcc7}
  COMPATIBLE=${COMPATIBLE/gcc73/gcc7}
fi

if [[ $(uname -s) == Linux ]]; then
  LCG_EXTERNALS=/cvmfs/sft.cern.ch/lcg/views/$EXTERNALS
  if [[ -e $LCG_EXTERNALS/$PLATFORM/setup.sh ]]; then
    source $LCG_EXTERNALS/$PLATFORM/setup.sh
  elif [[ -e $LCG_EXTERNALS/$COMPATIBLE/setup.sh ]]; then
    source $LCG_EXTERNALS/$COMPATIBLE/setup.sh
  elif [[ $PLATFORM == *slc6* || $PLATFORM == *centos7* ]]; then
    export PATH=/cvmfs/sft.cern.ch/lcg/contrib/CMake/3.6.0/Linux-$ARCH/bin:${PATH}
  else
    echo "No $EXTERNALS externals found for $PLATFORM"
  fi
fi

# The final compiler may not yet be totally setup-------------------------------------
if [[ $COMPILER == gcc* ]]; then
  export ExtraCMakeOptions="-Darrow=OFF ${ExtraCMakeOptions}"
  if [ $ARCH != i686 ]; then
    export ExtraCMakeOptions="-Dbuiltin_lzma=ON ${ExtraCMakeOptions}"
  fi

  if [[ $COMPILER == gcc73 ]]; then
    source /cvmfs/sft.cern.ch/lcg/contrib/gcc/7.3.0binutils/${COMPATIBLE}/setup.sh || exit 1
    export PATH=/cvmfs/sft.cern.ch/lcg/contrib/gcc/7.3.0binutils/${COMPATIBLE}/bin:$PATH
  fi
elif [[ $COMPILER == clang_gcc* ]]; then
  # We are cross compiling. We use clang as a compiler with libstdc++.
  # Get the gcc version. First parameter is a zero-based offset and the second is the length.
  GCCcompiler=${COMPILER:6:5}
  GCCversion=${COMPILER:9:2}
  GCCversion="${GCCversion:0:1}.${GCCversion:1:1}"
  . /cvmfs/sft.cern.ch/lcg/contrib/gcc/${GCCversion}/${ARCH}-${LABEL}/setup.sh

  # FIXME: Horrible hack for finding the lcg releases on mac1012. They are under x86_64-mac1012-clang81-opt
  # We shouldn't use the compiler version to denote the toolchain which was used to compile the releases
  # but the version of the standard library. I.e. libcxx or libstdc++.
  if [[ $PLATFORM == *mac1012* ]]; then
      GCCcompiler="clang81"
  else
      . /cvmfs/sft.cern.ch/lcg/contrib/gcc/${GCCversion}/${ARCH}-${LABEL}/setup.sh
  fi

  export PATH=/cvmfs/sft.cern.ch/lcg/contrib/llvm/latest/x86_64-centos7-gcc48-opt/bin/:$PATH
  export CC=`which clang`
  export CXX=`which clang++`
  export ExtraCMakeOptions="${ExtraCMakeOptions} -Dfortran=OFF -Dhdfs=OFF"
  # On slc we want to compile with a more 'standard' toolchain.
  if [[ $PLATFORM == *slc* ]] || [[ $LABEL == *centos7* ]] ; then
    export ExtraCMakeOptions="${ExtraCMakeOptions} -Dgcctoolchain=$(dirname $(dirname `which gcc`))"
  fi

elif [[ $COMPILER == *clang* ]]; then
  clang34version=3.4
  clang35version=3.5
  clang36version=3.6
  clang37version=3.7
  clang38version=3.8
  clang39version=3.9
  clang50version=5.0
  clang500version=5.0.0
  clang501version=5.0.1
  clang600version=6.0.0binutils
  clang501binutilsversion=5.0.1binutils
  clang600binutilsversion=6.0.0binutils
  COMPILERversion=${COMPILER}version
  clang34gcc=4.8
  clang35gcc=4.9
  clang36gcc=4.9
  clang37gcc=4.9
  clang38gcc=4.9
  clang39gcc=6.2
  clang50gcc=6.2
  clang500gcc=6.2
  clang501gcc=6.2
  clang501binutilsgcc=6.2
  clang600binutilsgcc=6.2
  clang600gcc=6.2
  GCCversion=${COMPILER}gcc
  . /cvmfs/sft.cern.ch/lcg/contrib/llvm/${!COMPILERversion}/${COMPATIBLE}/setup.sh

  export CC=`which clang`
  export CXX=`which clang++`
  export ExtraCMakeOptions="${ExtraCMakeOptions} -Dfortran=OFF -Doracle=OFF"

  # On slc we want to compile with a more 'standard' toolchain.
  if [[ $PLATFORM == *slc* ]] || [[ $LABEL == *centos7* ]] ; then
    export ExtraCMakeOptions="${ExtraCMakeOptions} -Dgcctoolchain=$(dirname $(dirname `which gcc`))"
  fi
elif [[ $COMPILER == *native* ]]; then
  unset CC
  unset CXX
  unset FC
  export ExtraCMakeOptions="${ExtraCMakeOptions}"
  if [[ $LABEL == *mac* ]]; then
    export ExtraCMakeOptions="-Dmacos_native=ON -Doracle=OFF ${ExtraCMakeOptions}"
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
      . /cvmfs/projects.cern.ch/intelsw/psxe/linux/17-all-setup.sh
  elif [ $COMPILER == icc18 ]; then
      . /cvmfs/projects.cern.ch/intelsw/psxe/linux/18-all-setup.sh
  else
      . /afs/cern.ch/sw/lcg/contrib/gcc/${!GCCversion}/${ARCH}-slc6/setup.sh
      . /afs/cern.ch/sw/IntelSoftware/linux/setup.sh
      . /afs/cern.ch/sw/IntelSoftware/linux/${ARCH}/xe${!COMPILERyear}/bin/ifortvars.sh intel64
      . /afs/cern.ch/sw/IntelSoftware/linux/${ARCH}/xe${!COMPILERyear}/bin/iccvars.sh intel64
  fi
  export CC=`which icc`
  export CXX=`which icc`
  export FC=`which ifort`
fi

case $ARCH in
  ppc64le)
    # The ppc64le build node does not have X11 or GSL installed
    export ExtraCMakeOptions="${ExtraCMakeOptions} -Dx11=OFF -Dbuiltin_gsl=ON"
    export ExtraCMakeOptions="${ExtraCMakeOptions} -Dbuiltin_afterimage=OFF"
    export ExtraCMakeOptions="${ExtraCMakeOptions} -Dasimage=OFF -Dastiff=OFF"
  ;;
esac


if [[ $LABEL == slc6 || $LABEL == centos7 ]]; then
    export CCACHE_BASEDIR=/mnt/build/jenkins/workspace/
    export CCACHE_DIR=/ccache
    export CCACHE_MAXSIZE=10G
fi

# Set PYTHON_EXECUTABLE variable if BUILDOPTS is python3
if [[ "$BUILDOPTS" == "python3" ]]; then
    export ExtraCMakeOptions="${ExtraCMakeOptions} -DPYTHON_EXECUTABLE=$(which python3)"
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
