# Define custom utilities
# Test for macOS with [ -n "$IS_MACOS" ]

if [ -n "$IS_MACOS" ]; then
    export QUIP_ARCH=darwin_x86_64_gfortran
else
    export QUIP_ARCH=linux_x86_64_gfortran
fi

source gfortran-install/gfortran_utils.sh

function pre_build {
    # fetch and install OpenBLAS in same way as its done for numpy
    build_openblas

    # setup architecture-specific build environment
    [[ -d ${REPO_DIR} ]] || mkdir -p ${REPO_DIR}
    cp Makefile.inc ${REPO_DIR}

    (cd ${REPO_DIR}/../.. && make quippy)

    # get ready to run `pip wheel` in build directory
    cp ${REPO_DIR}/../../quippy/setup.py ${REPO_DIR}
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    cd ${REPO_DIR}/../../tests
    python3 run_all.py -v
}
