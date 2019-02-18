#!/bin/bash

MYIP="$1"
SOURCE=/usr/local/bin/mvs.conf
TARGET=~/.metaverse/mvs.conf

# if both target and source does not exists, then report error and exit
# if target exists, and it is not older than source, then do nothing
if [[ ! -f ${SOURCE} ]]; then
    if [[ ! -f ${TARGET} ]]; then
        echo "${SOURCE} NOT EXIST!!!"
        exit 1
    else
        exit 0
    fi
elif [[ -f ${TARGET} ]] && [[ ! ${TARGET} -ot ${SOURCE} ]]; then
    exit 0
fi

if [[ -z "$MYIP" ]]; then
    # loop 3 times, consider the network status.
    if [[ -n "$(which curl)" ]]; then
        for n in $(seq 3); do
            if [[ -z "$MYIP" ]]; then
                MYIP=$(curl -sS ifconfig.me)
            fi
            if [[ -z "$MYIP" ]]; then
                MYIP=$(curl -sS ifconfig.co)
            else
                break
            fi
        done
    fi
fi

mkdir -p $(dirname ${TARGET})
cp -f ${SOURCE} ${TARGET}

sed -i 's/127.0.0.1:8820/0.0.0.0:8820/g' ${TARGET}
sed -i 's/127.0.0.1:8821/0.0.0.0:8821/g' ${TARGET}

if [[ -n "$MYIP" ]]; then
    sed -i "/\[network\]/a self=${MYIP}:5251" ${TARGET}
fi
