#!/bin/bash

print_usage() {
    echo "$0 [-t] [self-ip-address]"
    echo "if -t is specified, then run testnet"
    echo "if self-ip-address is specified, then config self inbound ip address"
}

run_testnet="false"
if [[ "$1" = "-t" ]]; then
    run_testnet="true"
    shift
fi

# step 1: config mvs.conf
/usr/local/bin/setup_mvs_conf.sh "$@"

# step 2: run mvsd
if [[ "$run_testnet" = "false" ]]; then
    /usr/local/bin/mvsd
else
    /usr/local/bin/mvsd -t -c mvs.conf
fi
