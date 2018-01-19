#!/bin/bash

# loop 3 times, consider the network status.
for n in $(seq 3); do
    if [ -z "$MYIP" ]; then
        MYIP=`curl ifconfig.me`
    else
        break
    fi
done

TARGET=~/.metaverse/mvs.conf

mkdir -p ~/.metaverse/

if [ ! -f ${TARGET} ]; then
    cp /usr/local/etc/mvs.conf ${TARGET}
    sed -i 's/127.0.0.1:8820/0.0.0.0:8820/g' ${TARGET}
    sed -i "/\[network\]/a self=${MYIP}:5251" ${TARGET}
fi
