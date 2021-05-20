# Define custom utilities
# Test for macOS with [ -n "$IS_MACOS" ]

source gfortran-install/gfortran_utils.sh

function build_libs {
    build_openblas
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
