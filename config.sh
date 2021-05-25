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
    cp Makefile.${PLAT}.inc ${REPO_DIR}/Makefile.inc

    (cd ${REPO_DIR}/../.. && make quippy)

    # get ready to run `pip wheel` in build directory
    cp ${REPO_DIR}/../../quippy/setup.py ${REPO_DIR}
}

# override install_run from multibuild, since we need to access the tests from repo root
function install_run {
    install_wheel
    cd /io/QUIP/tests
    python3 run_all.py -v
}