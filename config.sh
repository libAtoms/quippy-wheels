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

function install_delocate {
    check_pip
    $PIP_CMD install git+https://github.com/isuruf/delocate.git@arm64
}

function pip_opts {
    [ -n "$MANYLINUX_URL" ] && echo "-v --find-links $MANYLINUX_URL" || echo "-v"
}

# customize setup of cross compiler to remove -Wl,-rpath options that stop delocate from working correctly
function macos_arm64_cross_build_setup {
    echo Running custom macos_arm64_cross_build_setup
    # Setup cross build for single arch arm_64 wheels
    export PLAT="arm64"
    export BUILD_PREFIX=/opt/arm64-builds
    sudo mkdir -p $BUILD_PREFIX/lib $BUILD_PREFIX/include
    sudo chown -R $USER $BUILD_PREFIX
    update_env_for_build_prefix
    export _PYTHON_HOST_PLATFORM="macosx-11.0-arm64"
    export CFLAGS+=" -arch arm64"
    export CXXFLAGS+=" -arch arm64"
    export CPPFLAGS+=" -arch arm64"
    export ARCHFLAGS+=" -arch arm64"
    export FCFLAGS+=" -arch arm64"
    export FC=$FC_ARM64
    export MACOSX_DEPLOYMENT_TARGET="11.0"
    export CROSS_COMPILING=1
    local libgfortran="$(find /opt/gfortran-darwin-arm64/lib -name libgfortran.dylib)"
    local libdir=$(dirname $libgfortran)
    export FC_ARM64_LDFLAGS="-L$libdir -Wl,-rpath,$libdir"
    export LDFLAGS+=" -arch arm64 -L$BUILD_PREFIX/lib $FC_ARM64_LDFLAGS"
    # This would automatically let autoconf know that we are cross compiling for arm64 darwin
    export host_alias="aarch64-apple-darwin20.0.0"
}


function pre_build {    
    install_gfortran
    
    if [ -n "$IS_MACOS" ] && [ $PLAT == "arm64" ]; then
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
    else
      build_openblas
    fi

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

    # include `quip` and `gap_fit` command line tools and `libquip.a` library
    cp ${REPO_DIR}/quip ${REPO_DIR}/quippy
    cp ${REPO_DIR}/gap_fit ${REPO_DIR}/quippy/
    cp ${REPO_DIR}/libquip.a ${REPO_DIR}/quippy/
}

# override install_run from multibuild, since we need to access the tests from repo root
function install_run {
    if [ "$PLAT" == "arm64" ]; then
    	echo Skipping test for cross-compiled wheel $PLAT
	return
    fi 
    install_wheel
    cd QUIP/tests
    QUIP_TEST_IN_PLACE=0 HAVE_GAP=1 python3 run_all.py -v
}
