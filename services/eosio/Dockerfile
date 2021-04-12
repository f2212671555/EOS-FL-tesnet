FROM ubuntu:18.04

# Install Libraries
# jq for json
# cmake for build eosio.cdt, build-essential for cmake
RUN apt-get update && apt-get -y upgrade &&\
    apt-get install -y wget nano jq curl git cmake build-essential
    # apt-get install -y autotools-dev automake  gcc pkg-config

COPY ./ /opt/application

ENV EOSIO_PACKAGE_URL https://github.com/eosio/eos/releases/download/v2.0.7/eosio_2.0.7-1-ubuntu-18.04_amd64.deb
ENV EOSIO_CDT_OLD_URL https://github.com/eosio/eosio.cdt/releases/download/v1.6.3/eosio.cdt_1.6.3-1-ubuntu-18.04_amd64.deb
ENV EOSIO_CDT_URL https://github.com/EOSIO/eosio.cdt/releases/download/v1.7.0/eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb

RUN wget -O /eosio.deb $EOSIO_PACKAGE_URL \
  && wget -O /eosio-cdt-v1.7.0.deb $EOSIO_CDT_URL \
  && wget -O /eosio-cdt-v1.6.3.deb $EOSIO_CDT_OLD_URL

RUN apt-get install -y /eosio.deb

RUN apt-get install -y /eosio-cdt-v1.6.3.deb \
  && git clone https://github.com/EOSIO/eosio.contracts.git /opt/old-eosio.contracts \
  && cd /opt/old-eosio.contracts && git checkout release/1.8.x \
  && rm -fr build \
  && mkdir build  \
  && cd build \
  && cmake .. \
  && make -j$(sysctl -n hw.ncpu)

RUN apt-get install -y /eosio-cdt-v1.7.0.deb \
  && git clone https://github.com/eoscostarica/eosio.contracts.git /opt/eosio.contracts \
  && cd /opt/eosio.contracts && git checkout release/1.9.x \
  && rm -fr build \
  && mkdir build  \
  && cd build \
  && cmake .. \
  && make -j$(sysctl -n hw.ncpu)

# Remove all of the unnecessary files and apt cache
RUN rm -Rf /eosio*.deb \
#   && apt-get remove -y wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV EOSIO_OLD_CONTRACTS_DIRECTORY /opt/old-eosio.contracts/build/contracts
ENV EOSIO_CONTRACTS_DIRECTORY /opt/eosio.contracts/build/contracts

WORKDIR /opt/application/utils
# Install EOSIO
# Installed in /usr/opt/eosio
# RUN \
#     # wget https://github.com/EOSIO/eos/releases/download/v2.0.10/eosio_2.0.10-1-ubuntu-18.04_amd64.deb &&\
#     apt -y install ./eosio_2.0.10-1-ubuntu-18.04_amd64.deb
#     # rm -r eosio_2.0.10-1-ubuntu-18.04_amd64.deb

# Install EOS Contract Development Toolkit
# Installed in /usr/opt/eosio.cdt
# RUN \
#     # wget https://github.com/EOSIO/eosio.cdt/releases/download/v1.7.0/eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb &&\
#     apt -y install ./eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb
#     # rm -r eosio.cdt_1.7.0-1-ubuntu-18.04_amd64.deb

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
WORKDIR /opt/application/contracts
WORKDIR /opt/system_contracts

# used by /opt/application/scripts/start.sh
ENV DATA_DIR /root/data-dir
ENV CONFIG_DIR /opt/application/config

# used by /opt/application/scripts/init_chain.sh
ENV SYSTEM_CONTRACTS_DIR: /opt/system_contracts
ENV CONTRACTS_DIR /opt/contracts

# set scripts permission
RUN chmod 777 /opt/application/scripts/*.sh

# coder-server
EXPOSE 8080
ENV PASSWORD eospc

RUN wget https://github.com/cdr/code-server/releases/download/3.1.1/code-server-3.1.1-linux-x86_64.tar.gz \
    && tar zxvf code-server-3.1.1-linux-x86_64.tar.gz \
    && rm -r code-server-3.1.1-linux-x86_64.tar.gz

#https://github.com/ml-tooling/ml-workspace/blob/develop/Dockerfile#L930
RUN \
    # Make zsh the default shell
    chsh -s $(which bash) root

# setting code-server default to bash and resize font
RUN mkdir -p /root/.local/share/code-server/User &&\
    touch /root/.local/share/code-server/User/settings.json &&\
    echo '{"editor.fontSize": 18,"terminal.integrated.fontSize": 16,"terminal.integrated.shell.linux": "/bin/bash",}' >> /root/.local/share/code-server/User/settings.json
# run code server   
ENTRYPOINT ./code-server-3.1.1-linux-x86_64/code-server --host 0.0.0.0  >> codeserver.txt