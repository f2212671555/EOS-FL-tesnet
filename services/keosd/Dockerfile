FROM ubuntu:18.04

RUN apt-get update && apt-get -y upgrade &&\
    apt-get install -y wget nano jq curl git

# Install EOSIO
RUN wget https://github.com/EOSIO/eos/releases/download/v2.0.10/eosio_2.0.10-1-ubuntu-18.04_amd64.deb &&\
    apt -y install ./eosio_2.0.10-1-ubuntu-18.04_amd64.deb &&\
    rm -r eosio_2.0.10-1-ubuntu-18.04_amd64.deb