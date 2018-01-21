#!/bin/bash

# step 1: config mvs.conf
/usr/local/bin/setup_mvs_conf.sh

# step 2: run mvsd
/usr/local/bin/mvsd "$@"
