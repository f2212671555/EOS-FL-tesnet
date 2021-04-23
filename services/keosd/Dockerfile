FROM ubuntu:18.04

# Install Libraries
# jq for json
# cmake for build eosio.cdt, build-essential for cmake
RUN apt-get update && apt-get -y upgrade \
    && apt-get install -y wget nano jq curl git cmake build-essential sudo \
    && apt-get install -y python3-pip g++ psmisc openssl libssl-dev net-tools vim

# install eosio
RUN wget https://github.com/eosio/eos/releases/download/v2.0.11/eosio_2.0.11-1-ubuntu-18.04_amd64.deb
RUN apt-get install -y ./eosio_2.0.11-1-ubuntu-18.04_amd64.deb

COPY ./ /opt/application
# will be used in setup.sh which is in /opt/application/scripts
ENV WALLET_DIR /opt/eosio-wallet
ENV LOGS_DIR /opt/application/logs
# run keosd in this ip:port
ENV HTTP_SERVER_ADDRESS 0.0.0.0:6666

# set scripts permission
RUN chmod 777 /opt/application/scripts/*.sh