#!/bin/bash

export PLAT=universal2
export MB_PYTHON_VERSION=3.9

export QUIP_ARCH=darwin_x86_64_gfortran_openmp
export REPO_DIR=QUIP/build/${QUIP_ARCH}

export BUILD_DEPENDS=oldest-supported-numpy
export TEST_DEPENDS=numpy

#(cd QUIP && make distclean)
rm -f openblas-stamp

source multibuild/common_utils.sh
source multibuild/travis_osx_steps.sh
before_install
build_wheel $REPO_DIR $PLAT
install_run $PLAT
