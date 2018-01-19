#!/bin/bash

if [ ! -f /opt/mvs_build/setup_mvs_conf.sh ]; then
    echo "/opt/mvs_build/setup_mvs_conf.sh not exist!!!"
    exit 1
fi

echo 'APT::Install-Recommends 0;' >> /etc/apt/apt.conf.d/01norecommends
echo 'APT::Install-Suggests 0;' >> /etc/apt/apt.conf.d/01norecommends

# UPDATE repo
apt-get update

# INSTALL tools
apt-get install -q -y sudo wget curl net-tools ca-certificates unzip \
    git-core automake autoconf libtool build-essential cmake \
    pkg-config libtool apt-utils mpi-default-dev \
    libicu-dev libbz2-dev zlib1g-dev openssl libssl-dev libgmp-dev

# setup gmp link => without-bignum
export IS_TRAVIS_LINUX=1

# if source files is not copied, then clone it.
if [ ! -d /opt/mvs_build/metaverse ]; then
    cd /opt/mvs_build
    echo "git clone git@github.com:mvs-org/metaverse.git"
    git clone git@github.com:mvs-org/metaverse.git
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

# install dependencies
/bin/bash install_dependencies.sh --build-boost

# build and install metaverse
mkdir -p build && cd build && cmake .. && make -j2 && make install

# config mvs
if [ ! -f /usr/local/etc/mvs.conf ]; then
    cp /opt/mvs_build/metaverse/etc/mvs.conf /usr/local/etc/mvs.conf
fi
cp /opt/mvs_build/setup_mvs_conf.sh /usr/local/bin/setup_mvs_conf.sh
/bin/bash /usr/local/bin/setup_mvs_conf.sh

# TODO...
# Should has `make test` here
# make test

# do cleaning jobs at last
rm -rf /var/lib/apt/lists/*
rm -rf /opt/mvs_build
