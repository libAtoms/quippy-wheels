# Define custom utilities
# Test for macOS with [ -n "$IS_MACOS" ]

source gfortran-install/gfortran_utils.sh

function _build_wheel {
    build_libs
    build_bdist_wheel $@
}

function build_wheel {
    if [ -n "$IS_MACOS" ]; then
        install_gfortran
    fi
    echo gcc --version
    echo `gcc --version`
    # Fix version error for development wheels by using bdist_wheel
    wrap_wheel_builder _build_wheel $@
}

function build_libs {
    # setuptools v49.2.0 is broken
    $PYTHON_EXE -mpip install --upgrade "setuptools<49.2.0"
    # Use the same incantation as numpy/tools/travis-before-install.sh to
    # download and un-tar the openblas libraries. The python call returns
    # the un-tar root directory, then the files are copied into /usr/local.
    # Could utilize a site.cfg instead to prevent the copy.
    $PYTHON_EXE -mpip install urllib3
    $PYTHON_EXE -c"import platform; print('platform.uname().machine', platform.uname().machine)"
    curl https://raw.githubusercontent.com/numpy/numpy/623bc1fae1d47df24e7f1e29321d0c0ba2771ce0/tools/openblas_support.py -o openblas_support.py
    basedir=$($PYTHON_EXE openblas_support.py)
    $use_sudo cp -r $basedir/lib/* $BUILD_PREFIX/lib
    $use_sudo cp $basedir/include/* $BUILD_PREFIX/include
    export OPENBLAS=$BUILD_PREFIX
}

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository
    export QUIP_ARCH=linux_x86_64_gfortran
    cd ${REPO_DIR}
    mkdir -p build/${QUIP_ARCH}
    cp ../Makefile.inc build/${QUIP_ARCH}/Makefile.inc
    make quippy
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    cd ${REPO_DIR}/tests
    python3 run_all.py -v
}
