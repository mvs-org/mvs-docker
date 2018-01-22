# directory layout
***

```tree
.
├── Dockerfile
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
> ENTRYPOINT ["/usr/local/bin/run_mvsd.sh"]

If you are familiar with docker and want to do your own configuration, you may still built it from image `jowenshaw/metaverse`.

If you want an image only includes metaverse binaries (`mvsd`, `mvs-cli` in /usr/local/bin), and scripts (`setup_mvs_conf.sh` `run_mvsd.sh` in /usr/local/bin), and config template (`mvs.conf` in /usr/local/etc), you can use another image **`jowenshaw/metaverse-wallet`**. This image is built from `ubuntn:16.04`, only include some executable / script / config files, and installed `curl` which is used by `setup_mvs_conf.sh`. So you need config and run this image with more parameters, or build a new image base on it to do the config jobs.

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
ENTRYPOINT ["/usr/local/bin/run_mvsd.sh"]
```


# Usage
***

## Start docker container
```bash
# run mvsd
docker run -p 8820:8820 metaverse
```

```bash
# run mvsd with more parameters
docker run --name=metaverse --privileged \
    -v /home/jowen/.metaverse:/root/.metaverse \
    -p 8820:8820 -p 5251:5251 -p 8821:8821 metaverse
```
> `--name=metaverse` will specify the container a name, you can use the name instead of container id or a hard to remember generated name.

> `-v /home/jowen/.metaverse:/root/.metaverse` will mount the container path /root/.metaverse to host path /home/jowen/.metaverse, now you can look the data in the host directly.

> `-p 8820:8820 -p 5251:5251 -p 8821:8821` bind ports, you can use `docker port metaverse` to see the port bindings.

> and you can use `docker inspect metaverse` to see more information, include the above infos.


## Test
```bash
# use curl to call APIs
curl -X POST --data '{"jsonrpc":"2.0","method":"getinfo","params":[],"id":25}' http://127.0.0.1:8820/rpc/v2
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

