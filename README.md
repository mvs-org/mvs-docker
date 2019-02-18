# directory layout
***

```tree
.
├── Dockerfile
├── mvs_binary
│   ├── bin
│   │   ├── mvs.conf
│   │   ├── run_mvsd.sh
│   │   └── setup_mvs_conf.sh
│   └── Dockerfile
├── mvs_build
│   ├── aliyun_sources.list
│   ├── build_metaverse_image.sh
│   ├── get_source_codes.sh
│   ├── run_mvsd.sh
│   └── setup_mvs_conf.sh
└── README.md
```

# Install 
***

## install Docker
> curl -sSL https://get.docker.com/ | sh

### Docker basic commands
In general, docker need root privilege, you can alias it  
> alias docker='sudo docker'

> docker help  
> docker version  
> docker images  
> docker ps  
> docker build  
> docker cp  
> docker run  
> docker stop / start / restart  
> docker exec

# build metaverse docker image
***

## clone mvs-docker.git

> git clone https://github.com/metaverse/mvs-docker.git

> cd mvs-docker

## binary version

**Binary version needs no building, just pull it down and use it directly. It has smaller image size than build from source, and can save a lot of time of compiling.**

> \# just pull it down, you can use this image directly  
> docker pull jowenshaw/metaverse

> \# if you feel the image name is hard to remember, you can tag it a new name  
> docker tag jowenshaw/metaverse metaverse-binary

One thing to mention, the above image **`jowenshaw/metaverse`** is easily to use, it has installed package `curl` and setted the default configuration, including the following
> VOLUME [~/.metaverse]  
> EXPOSE 5251 8820 8821  
> ENTRYPOINT ["run_mvsd.sh"]

If you are familiar with docker and want to do your own configuration, you may still built it from image `jowenshaw/metaverse`.

**Another way, you can build the docker by the `Dockerfile` in directory `mvs_binary`**
> cd mvs_binary
> # copy mvsd and mvs-cli to bin directory
> docker build -t metaverse -f Dockerfile .

actually, the `jowenshaw/metaverse` is built through the above way.

## build version

**Build from source is slowly but is more elastic, you can choose which version of source code to build.**

> \# clone / wget source code at local, and copy them to docker image.  
> \# This saves time to download source codes.  
> \# And, this way you can change the sources at locally, and build it in the image.  
> \# If you do not provide source codes here, the container will run get_source_codes.sh to get them.  
> \# So get source codes here is not a must step.  
> \# The only difference is the speed of downloading source codes.  
> ./mvs_build/get_source_codes.sh

> docker build -t metaverse -f Dockerfile .


# Dockerfile content
***

## binary version

**binary image is now directly usable, just pull it down, and use it directly.**

If you want to build from the binary with Dockerfile in `mvs_binary`, the following is the content.

**File Content**
```file
FROM ubuntu:16.04

# copy mvsd mvs-cli mvs.conf and auxiliary scripts
COPY ./bin /usr/local/bin

VOLUME [~/.metaverse]

# 5251 : P2P Network
# 8820 : JSON-RPC CALL
# 8821 : Websocket notifcations
EXPOSE 5251 8820 8821

ENTRYPOINT ["run_mvsd.sh"]
```

## build version

**File Content**
```file
FROM ubuntu:16.04

# copy source codes and scripts and other auxiliary tools, all in mvs_build dir
COPY ./mvs_build /opt/mvs_build

# run build_metaverse_image.sh, the first param is the apt sources.list file
# which will replace /etc/apt/sources.list with /opt/mvs_build/$1 in the image.
# if the first param is empty, then use official sources which maybe slower.
RUN cd /opt/mvs_build && /bin/bash build_metaverse_image.sh aliyun_sources.list

VOLUME [~/.metaverse]

# 5251 : P2P Network
# 8820 : JSON-RPC CALL
# 8821 : Websocket notifcations
EXPOSE 5251 8820 8821

# run_mvsd.sh will call setup_mvs_conf.sh, then run mvsd.
# this way can ensure the config is always updated when create a new container.
ENTRYPOINT ["run_mvsd.sh"]
```


# Usage
***

## Start docker container
```bash
# run mvsd
docker run -p 8820:8820 metaverse
or,
# specify the container name,
docker run --name=metaverse -p 8820:8820 metaverse
or,
# run in the background,
docker run -d --name=metaverse -p 8820:8820 metaverse
```

```bash
# run mvsd with more parameters
docker run --name=metaverse --privileged \
    -v /opt/ChainData/Metaverse/Mainnet:/root/.metaverse \
    -p 5251:5251 -p 8820:8820 -p 8821:8821 metaverse

# run mvsd testnet with different port number
docker run --name=metaverse-testnet --privileged \
    -v /opt/ChainData/Metaverse/Testnet:/root/.metaverse \
    -p 15251:5251 -p 18820:8820 -p 18821:8821 metaverse -t 10.10.10.123
```

> `--name=metaverse` will specify the container a name, you can use the name instead of container id or a hard to remember generated name.

> `-v /home/jowen/.metaverse:/root/.metaverse` will mount the container path /root/.metaverse to host path /home/jowen/.metaverse, now you can look the data in the host directly.

> `-p 8820:8820 -p 5251:5251 -p 8821:8821` bind ports, you can use `docker port metaverse` to see the port bindings.

> and you can use `docker inspect metaverse` to see more information, include the above infos.

> `-t` if specified, then run the testnet.

> `10.10.10.123` if specified, is the ip address which can be specified to the config item `network.self`

## Test
```bash
# use curl to call APIs
curl -X POST --data '{"jsonrpc":"2.0","method":"getinfo","params":[],"id":25}' http://127.0.0.1:8820/rpc/v3
```

## Execute mvs-cli commands
Run `mvs-cli` commands via `docker exec` command. Example:
```bash
# a0d2fb92dff8 here is the container id created from image `metaverse`
# you can `docker ps` to get it, and replace it with your container id.
docker exec a0d2fb92dff8 mvs-cli getinfo

# this id/name is hard to remember, you can rename it
docker rename a0d2fb92dff8 metaverse

# now, you can use the new name instead of container id or old name
docker exec metaverse mvs-cli getinfo
```

Sometimes you want to modify the metaverse config file manually after the container is started.
(for example, modify the network.self config item),
you can copy out the original config file and copy back to the container.
(usr metaverse as the container id/name in this example)
```bash
# copy out the original config file
docker exec metaverse cp /root/.metaverse/mvs.conf ./
# after editting, copy it back to the container
docker exec metaverse cp ./mvs.conf /root/.metaverse/mvs.conf
# restart the container to make the modification effective
docker restart metaverse
```
