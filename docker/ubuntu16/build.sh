#!/bin/bash

set -x
set -e

if [ $# -ge 3 ]; then
  LABEL=$1 ; shift
  COMPILER=$1 ; shift
  BUILDTYPE=$1 ; shift
else
  echo "$0: expecting 3 arguments [LABEL] [COMPILER] [BUILDTYPE]"
  exit 1
fi

sudo chown builder: -R /ccache

# Setup build env
cd /root-build

export CCACHE_DIR=/ccache
export JENKINS_HOME=/tmp
export EXTERNALS=docker
export WORKSPACE=$(pwd)

export EMPTY_BINARY=true
export MODE=experimental

export LABEL
export COMPILER
export BUILDTYPE

export PYTHIA8DATA=/usr/share/pythia8-data/xmldoc
export PYTHIA8=/usr/

export ExtraCMakeOptions="-DCMAKE_INSTALL_PREFIX=/usr/local -Dall=ON -Dchirp=OFF -Ddcache=ON -Dfail-on-missing=ON -Dgnuinstall=ON -Drpath=ON -Dbonjour=ON -Dbuiltin_afterimage=ON -Dbuiltin_davix=ON -Dbuiltin_ftgl=OFF -Dbuiltin_gl2ps=OFF -Dbuiltin_glew=OFF -Dbuiltin_unuran=ON -Dbuiltin_xrootd=ON -Dcastor=OFF -Dfortran=ON -Dgeocad=OFF -Dglite=OFF -Dgviz=ON -Djemalloc=ON -Dkrb5=ON -Dldap=ON -Dodbc=OFF -Doracle=OFF -Dpythia6=OFF -Drfio=OFF -Dsapdb=OFF -Dsrp=OFF -Dvc=OFF -Dvdt=OFF -Dveccore=OFF"

# Build
rootspi/jenkins/jk-all build
# Install
sudo cmake -P build/cmake_install.cmake
# Test
rootspi/jenkins/jk-all test
# Stash test reports and cleanup
rm -rf Testing
cp -r build/Testing Testing
rm -rf build
