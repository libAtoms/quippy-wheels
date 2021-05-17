# Define custom utilities
# Test for macOS with [ -n "$IS_MACOS" ]

function pre_build {
    # Any stuff that you need to do before you start building the wheels
    # Runs in the root directory of this repository.
    cd ${REPO_DIR}
    mkdir -p build/${QUIP_ARCH}
    cp travis/Makefile.inc build/${QUIP_ARCH}/Makefile.inc
    make quippy
}

function run_tests {
    # Runs tests on installed distribution from an empty directory
    cd ${REPO_DIR}/tests
    python3 run_all.py -v
}
