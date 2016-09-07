#!/bin/bash

# Command used to run the tests
TEST_COMMAND="make test"

function run_test {
    echo "Running tests"
    echo "Environment: $(uname -a)"

    ${TEST_COMMAND}
}

if [ -e "/.chroot_is_done" ]; then
    # We are inside ARM chroot
    echo "Running inside chrooted environment"

    . ./envvars.sh
    run_test
else
    if [ "${ARCH}" = "arm" ]; then
        # Call ourselves again which will cause tests to run
        sudo chroot ${CHROOT_DIR} bash -c "cd ${TRAVIS_BUILD_DIR} && ./scripts/qemu-test.sh"
    else
        run_test
    fi
fi

