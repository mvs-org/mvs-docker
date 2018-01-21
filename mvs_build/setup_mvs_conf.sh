#!/bin/bash

SOURCE=/usr/local/etc/mvs.conf
TARGET=~/.metaverse/mvs.conf

# if both target and source does not exists, then report error and exit
if [ ! -f ${TARGET} ] && [ ! -f ${SOURCE} ]; then
    echo "${SOURCE} NOT EXIST!!!"
    exit 1
fi

# if target exists, and it is not older than source, then do nothing
if [ -f ${TARGET} ] && [ ! ${TARGET} -ot ${SOURCE} ]; then
    exit
fi

# loop 3 times, consider the network status.
for n in $(seq 3); do
    if [ -z "$MYIP" ]; then
        MYIP=`curl ifconfig.me`
    else
        break
    fi
done

mkdir -p $(dirname ${TARGET})
cp ${SOURCE} ${TARGET}

sed -i 's/127.0.0.1:8820/0.0.0.0:8820/g' ${TARGET}
sed -i "/\[network\]/a self=${MYIP}:5251" ${TARGET}
