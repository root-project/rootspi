#!/usr/bin/env bash
set -x
set -e

if [ $# -ge 4 ]; then
  LABEL=$1 ; shift
  COMPILER=$1 ; shift
  BUILDTYPE=$1 ; shift
  BRANCH=$1 ; shift
else
  echo "$0: expecting 4 arguments [LABEL] [COMPILER] [BUILDTYPE] [BRANCH]"
  exit 1
fi

# Setup build env
cd /root-build

export CCACHE_DIR=/ccache
export JENKINS_HOME=/tmp
export EXTERNALS=docker

export MODE=experimental
export ExtraCMakeOptions='-Dccache=ON -DCMAKE_INSTALL_PREFIX=/usr/local -Dgnuinstall=ON'

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
