# Define custom utilities
# Test for macOS with [ -n "$IS_MACOS" ]

source gfortran-install/gfortran_utils.sh

if [ -n "$IS_MACOS" ]; then
    export QUIP_ARCH=darwin_${PLAT}_gfortran
else
    export QUIP_ARCH=linux_${PLAT}_gfortran
fi

function pre_build {
    # fetch and install OpenBLAS in same way as its done for numpy
    build_openblas

    # setup architecture-specific build environment
    [[ -d ${REPO_DIR}/build/${QUIP_ARCH} ]] || mkdir -p ${REPO_DIR}/build/${QUIP_ARCH}
    cp ${REPO_DIR}/quippy/setup.py ${REPO_DIR}/build/${QUIP_ARCH}
    cp Makefile.inc ${REPO_DIR}/build/${QUIP_ARCH}

    cd ${REPO_DIR}
    make quippy

    # change into build directory before we run `pip wheel`
    cd build/${QUIP_ARCH}
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    cd ${REPO_DIR}/tests
    python3 run_all.py -v
}
