# Define custom utilities
# Test for macOS with [ -n "$IS_MACOS" ]

if [ -n "$IS_MACOS" ]; then
    if [ "$PLAT" == "arm64" ]; then
	export QUIP_ARCH=darwin_arm64_gfortran_openmp
    else
	export QUIP_ARCH=darwin_x86_64_gfortran_openmp
    fi
else
    export QUIP_ARCH=linux_x86_64_gfortran_openmp
fi

source gfortran-install/gfortran_utils.sh

# override pip options so we can build in place - needed on GHA
# function pip_opts {
#     [ -n "$MANYLINUX_URL" ] && echo -ne "--find-links $MANYLINUX_URL"
#     echo " --use-feature=in-tree-build"
# }

function install_delocate {
    check_pip
    $PIP_CMD install git+https://github.com/isuruf/delocate.git@arm64
}


function pre_build {    
    install_gfortran
    
    # fetch and install OpenBLAS in same way as its done for numpy
    # setuptools v49.2.0 is broken
    $PYTHON_EXE -mpip install --upgrade "setuptools<49.2.0"
    # Use the same incantation as numpy/tools/travis-before-install.sh to
    # download and un-tar the openblas libraries. The python call returns
    # the un-tar root directory, then the files are copied into /usr/local.
    # Could utilize a site.cfg instead to prevent the copy.
    $PYTHON_EXE -mpip install urllib3
    $PYTHON_EXE -c"import platform; print('platform.uname().machine', platform.uname().machine)"
    curl https://raw.githubusercontent.com/numpy/numpy/main/tools/openblas_support.py -o openblas_support.py
    basedir=$($PYTHON_EXE openblas_support.py)
    $use_sudo cp -r $basedir/lib/* $BUILD_PREFIX/lib
    $use_sudo cp $basedir/include/* $BUILD_PREFIX/include
    export OPENBLAS=$BUILD_PREFIX

    # install build dependencies (i.e. oldest supported numpy) before f90wrap,
    # otherwise we get too new a version
    pip install $(pip_opts) ${BUILD_DEPENDS}

    # setup architecture-specific build environment
    echo pre_build got REPO_DIR=$REPO_DIR
    [[ -d ${REPO_DIR} ]] || mkdir -p ${REPO_DIR}
    cp Makefile.${QUIP_ARCH}.inc ${REPO_DIR}/Makefile.inc

    export NPY_DISTUTILS_APPEND_FLAGS=1
    (cd ${REPO_DIR}/../.. && make quippy)

    # if we're building a release then use tag name as version
    if [[ -f GITHUB_TAG ]]; then
        cat GITHUB_TAG > ${REPO_DIR}/VERSION
    fi

    # get ready to run `pip wheel` in build directory
    cp ${REPO_DIR}/../../README.md ${REPO_DIR}
    cp ${REPO_DIR}/../../quippy/setup.py ${REPO_DIR}

    # include `quip` and `gap_fit` command line tools
    cp ${REPO_DIR}/quip ${REPO_DIR}/quippy
    cp ${REPO_DIR}/gap_fit ${REPO_DIR}/quippy/
}

# override install_run from multibuild, since we need to access the tests from repo root
function install_run {
    install_wheel
    cd QUIP/tests
    QUIP_TEST_IN_PLACE=0 HAVE_GAP=1 python3 run_all.py -v
}
