FROM ubuntu:16.04

# copy mvsd mvs-cli mvs.conf and auxiliary scripts
COPY ./bin /usr/local/bin

VOLUME [~/.metaverse]

# 5251 : P2P Network
# 8820 : JSON-RPC CALL
# 8821 : Websocket notifcations
EXPOSE 5251 8820 8821

ENTRYPOINT ["run_mvsd.sh"]
