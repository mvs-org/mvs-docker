#!/bin/bash

# get source codes in the same directory as this script is in.
dir=$(dirname "$0")
echo "cd $dir"
cd "$dir"

# use https://..., not git@...,
# as the later needs ssh which may be lack in container.
echo "git clone https://github.com/mvs-org/metaverse.git"
git clone https://github.com/mvs-org/metaverse.git
