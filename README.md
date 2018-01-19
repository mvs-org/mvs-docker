# directory layout
***

```tree
.
├── dockerfile
│   ├── Dockerfile_binary
│   └── Dockerfile_build
├── mvs_build
│   ├── build_metaverse_image.sh
│   ├── get_source_codes.sh
│   └── setup_mvs_conf.sh
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

# build metaverse docker image
***

## clone mvs-docker.git

> git clone https://github.com/metaverse/mvs-docker.git

> cd mvs-docker

## binary version

> **```Build from binary has smaller image size than build from source, and it is quickly to compelte building. Build from source is slowly but is more elastic, you can choose which version of source code to build.```**

> \# one line command is enough  
> docker build -t metaverse-binary -f ./dockerfile/Dockerfile_binary .

## build version

> \# clone/wget source code at local, and copy them to docker image.  
> \# This saves much time to download source codes.  
> ./mvs_build/get_source_codes.sh

> docker build -t metaverse -f ./dockerfile/Dockerfile_build .


# Dockerfile content
***

## binary version

```
FROM jowenshaw/metaverse-wallet:latest  
which is based on Ubuntu 16.04.

the tags indicate the binary version, like v0.7.3, latest, etc.

the image has the binary mvsd and mvs-cli, so only config jobs need to be done in Dockerfile.
```

**File Content**
```file
    FROM jowenshaw/metaverse-wallet:latest
    
    RUN /usr/local/bin/setup_mvs_conf.sh
    
    VOLUME [~/.metaverse]
    
    # P2P Network
    EXPOSE 5251
    # JSON-RPC CALL
    EXPOSE 8820
    # Websocket notifcations
    EXPOSE 8821
    
    ENTRYPOINT ["/usr/local/bin/mvsd"]
```

## build version

**File Content**
```file
    FROM ubuntu:16.04
    
    # copy source codes and shell scripts
    COPY ./mvs_build /opt/mvs_build
    
    RUN cd /opt/mvs_build && /bin/bash build_metaverse_image.sh
    
    VOLUME [~/.metaverse]
    
    # P2P Network
    EXPOSE 5251
    # JSON-RPC CALL
    EXPOSE 8820
    # Websocket notifcations
    EXPOSE 8821
    
    ENTRYPOINT ["/usr/local/bin/mvsd"]
```


# Usage

## Start docker container
```bash
# runs mvsd
docker run -p 8820:8820 metaverse
```

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

