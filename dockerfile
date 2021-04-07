FROM ubuntu:18.04

RUN apt-get update && apt-get install -y curl libicu60 libusb-1.0-0 libcurl3-gnutls

RUN apt-get install nano

# eosio
RUN curl -LO https://github.com/EOSIO/eos/releases/download/v2.0.10/eosio_2.0.10-1-ubuntu-18.04_amd64.deb \
    && dpkg -i eosio_2.0.10-1-ubuntu-18.04_amd64.deb
# eosio.cdt
RUN curl -LO https://github.com/EOSIO/eosio.cdt/releases/download/v1.8.0-rc2/eosio.cdt_1.8.0-rc2-ubuntu-18.04_amd64.deb \
    && dpkg -i eosio.cdt_1.8.0-rc2-ubuntu-18.04_amd64.deb

RUN curl -LO https://github.com/EOSIO/eosio.cdt/archive/v1.8.0-rc2.tar.gz && tar -xvzf v1.8.0-rc2.tar.gz --one-top-level=eosio.cdt --strip-components 1

RUN cd /eosio.cdt/ && curl -LO https://github.com/EOSIO/eosio.contracts/archive/v1.9.2.tar.gz && tar -xvzf v1.9.2.tar.gz --one-top-level=eosio.contracts --strip-components 1