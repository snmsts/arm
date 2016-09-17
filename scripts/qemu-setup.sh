#!/bin/bash
# Based on a test script from avsm/ocaml repo https://github.com/avsm/ocaml

MIRROR=http://archive.raspbian.org/raspbian
VERSION=wheezy

# Debian package dependencies for the host
HOST_DEPENDENCIES=${HOST_DEPENDENCIES:'debootstrap qemu-user-static binfmt-support sbuild'}

# Debian package dependencies for the chrooted environment
GUEST_DEPENDENCIES=${GUEST_DEPENDENCIES:'build-essential git m4 sudo python'}

function setup_armhf_chroot {
    # Host dependencies
    sudo apt-get install -qq -y ${HOST_DEPENDENCIES}

    # Create chrooted environment
    sudo mkdir -p ${CHROOT_DIR}
    sudo debootstrap --foreign --no-check-gpg --include=fakeroot,build-essential \
         --arch=${CHROOT_ARCH} ${VERSION} ${CHROOT_DIR} ${MIRROR}
    sudo cp /usr/bin/qemu-arm-static ${CHROOT_DIR}/usr/bin/
    sudo chroot ${CHROOT_DIR} ./debootstrap/debootstrap --second-stage
    sudo sbuild-createchroot --arch=${CHROOT_ARCH} --foreign --setup-only \
         ${VERSION} ${CHROOT_DIR} ${MIRROR}

    # Create file with environment variables which will be used inside chrooted
    # environment
    echo "export CHROOT_ARCH=${CHROOT_ARCH}" > envvars.sh
    echo "export TRAVIS_BUILD_DIR=${TRAVIS_BUILD_DIR}" >> envvars.sh
    chmod a+x envvars.sh

    # Install dependencies inside chroot
    sudo chroot ${CHROOT_DIR} apt-get update
    sudo chroot ${CHROOT_DIR} apt-get --allow-unauthenticated install \
         -qq -y ${GUEST_DEPENDENCIES}

    # Create build dir and copy travis build files to our chroot environment
    sudo mkdir -p ${CHROOT_DIR}/${TRAVIS_BUILD_DIR}

    # Indicate chroot environment has been set up
    sudo touch ${CHROOT_DIR}/.chroot_is_done

}

if [ "${CHROOT_ARCH}" = "armhf" ]; then
    # ARM test run, need to set up chrooted environment first
    echo "Setting up chrooted ARM environment"
    setup_armhf_chroot
fi
