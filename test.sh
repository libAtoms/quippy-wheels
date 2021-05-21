#!/bin/bash

export REPO_DIR=QUIP
export BUILD_COMMIT=e07c62af247
export PLAT=x86_64
export MB_PYTHON_VERSION=3.6

export QUIP_ARCH=linux_${PLAT}_gfortran

(cd QUIP && make distclean)
rm -f openblas-stamp

source multibuild/common_utils.sh
source multibuild/travis_linux_steps.sh
before_install
# clean_code $REPO_DIR $BUILD_COMMIT
build_wheel $REPO_DIR $PLAT
install_run $PLAT
