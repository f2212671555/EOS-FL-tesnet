FROM ubuntu:18.04

# Install Libraries
# jq for json
# cmake for build eosio.cdt, build-essential for cmake
RUN apt-get update && apt-get -y upgrade &&\
    apt-get install -y wget nano jq curl git cmake build-essential

COPY ./ /opt/application

WORKDIR /opt/application/utils
# Install EOSIO
# Installed in /usr/opt/eosio
RUN cd /opt/application/utils &&\
    wget https://github.com/EOSIO/eos/releases/download/v2.0.10/eosio_2.0.10-1-ubuntu-18.04_amd64.deb &&\
    apt -y install ./eosio_2.0.10-1-ubuntu-18.04_amd64.deb &&\
    rm -r eosio_2.0.10-1-ubuntu-18.04_amd64.deb

# Install EOS Contract Development Toolkit
# Installed in /usr/opt/eosio.cdt
RUN cd /opt/application/utils &&\
    wget https://github.com/EOSIO/eosio.cdt/releases/download/v1.7.0/eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb &&\
    apt -y install ./eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb &&\
    rm -r eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb

# Installed in /usr/local/eosio.cdt
# RUN cd /usr/local &&\
#     git clone --recursive https://github.com/eosio/eosio.cdt --branch v1.6.3 --single-branch &&\
#     cd eosio.cdt &&\
#     mkdir build &&\
#     cd build &&\
#     cmake .. &&\
#     make -j4 &&\
#     make install

# WORKDIR /opt/contracts
# make -j4, 4cpu
# RUN git clone --recursive https://github.com/eosio/eosio.cdt --branch v1.6.3 --single-branch
# RUN cd eosio.cdt &&\
#     ./build.sh
# RUN cd eosio.cdt &&\
#     sudo ./install.sh
# RUN cd eosio.cdt &&\
#     mkdir build &&\
#     cd build &&\
#     cmake .. &&\
#     make -j4 &&\
#     make install

VOLUME /opt/application
WORKDIR /opt/application


# used by /opt/application/scripts/start.sh
ENV DATA_DIR /root/data-dir
ENV CONFIG_DIR /opt/application/config
# used by /opt/application/scripts/init_chain.sh
WORKDIR /opt/application/contracts
ENV SYS_CONTRACTS_DIR /opt/application/contracts

ENV CONTRACTS_DIR /opt/contracts

## set scripts permission
RUN chmod 777 /opt/application/scripts/*.sh