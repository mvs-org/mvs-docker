FROM ubuntu:16.04

# copy source codes and scripts and other auxiliary tools, all in mvs_build dir
COPY ./mvs_build /opt/mvs_build

# run build_metaverse_image.sh, the first param is the apt sources.list file
# which will replace /etc/apt/sources.list with ./mvs_build/$1 in the image.
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
