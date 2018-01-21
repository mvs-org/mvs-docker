#!/bin/bash

if [ ! -f /opt/mvs_build/run_mvsd.sh ]; then
    echo "/opt/mvs_build/run_mvsd.sh not exist!!!"
    exit 1
fi

# UPDATE repo
if [ -n "$1" ] && [ -f "/opt/mvs_build/$1" ]; then
    echo "backup and replace /etc/apt/sources.list with /opt/mvs_build/$1"
    cp /etc/apt/sources.list /etc/apt/sources.list.bak
    cp "/opt/mvs_build/$1" /etc/apt/sources.list
    apt-get clean
fi
apt-get update

export DEBIAN_FRONTEND=noninteractive
APTOPTS="-qq -y --no-install-suggests --no-install-recommends"

# INSTALL tools
PACKAGES="apt-utils pkg-config libtool sudo wget curl net-tools unzip ca-certificates
    openssl libssl-dev libicu-dev libbz2-dev zlib1g-dev mpi-default-dev libgmp-dev
    automake autoconf build-essential cmake
    git"
echo "====== want to install the following packages ======"
echo ${PACKAGES}
echo

check_installed() {
    dpkg -l "$1" 2>/dev/null | \grep -Eq "^ii\s+$1[: \t]" || which "$1" &>/dev/null
}

# INSTALL tools, may fail on bad network context, try twice, exit when fail.
for PACKAGE in ${PACKAGES}; do
    check_installed ${PACKAGE} && echo "====== has already install package: ${PACKAGE}" && continue

    apt-get install ${APTOPTS} ${PACKAGE}
    check_installed ${PACKAGE} && echo "====== successfully install package: ${PACKAGE}" && continue

    echo "====== try again install package: ${PACKAGE}"
    apt-get install ${APTOPTS} ${PACKAGE}

    check_installed ${PACKAGE} || echo "====== failed to install package: ${PACKAGE}" && exit 1
done

# if source files is not copied, then get them.
if [ ! -d /opt/mvs_build/metaverse ]; then
    /bin/bash /opt/mvs_build/get_source_codes.sh
fi

cd /opt/mvs_build/metaverse

# doing some checking
if [ ! -f ./install_dependencies.sh ]; then
    echo "${PWD}/install_dependencies.sh not exist!!!"
    exit 1
fi
if [ ! -f ./etc/mvs.conf ]; then
    echo "${PWD}/etc/mvs.conf not exist!!!"
    exit 1
fi

# setup gmp link => without-bignum
export IS_TRAVIS_LINUX=1

# install dependencies
/bin/bash install_dependencies.sh --build-boost

# build and install metaverse
mkdir -p build && cd build && cmake .. && make -j2 && make install

# copy config file to /usr/local/etc/ dir
cp /opt/mvs_build/metaverse/etc/mvs.conf /usr/local/etc/mvs.conf

# copy scripts to /usr/local/bin/ dir
cp /opt/mvs_build/setup_mvs_conf.sh /usr/local/bin/setup_mvs_conf.sh
cp /opt/mvs_build/run_mvsd.sh /usr/local/bin/run_mvsd.sh

# TODO...
# Should has `make test` here
# make test


# do cleaning jobs at last, to decrease the size of docker image.

# remove source codes and scripts
rm -rf /opt/mvs_build

# remove temp and cached files
rm -rf /var/lib/apt/lists/*
rm -rf /tmp/* /var/tmp/*

# remove manual and doc
rm -rf /usr/share/doc/*
rm -rf /usr/share/man/*

# clear history
rm -rf ~/.bash_history
history -c
