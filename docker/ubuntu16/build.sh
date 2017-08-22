#!/usr/bin/env bash
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

sudo chown sftnight: -R /ccache

# Setup build env
cd /root-build

export CCACHE_DIR=/ccache
export JENKINS_HOME=/tmp
export EXTERNALS=docker
export WORKSPACE=$(pwd)

export MODE=experimental
export ExtraCMakeOptions='-Dccache=ON -DCMAKE_INSTALL_PREFIX=/usr/local -Dgnuinstall=ON -Drpath=ON -Dbuiltin_xrootd=ON -Dbuiltin_davix=ON'

export LABEL
export COMPILER
export BUILDTYPE

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
