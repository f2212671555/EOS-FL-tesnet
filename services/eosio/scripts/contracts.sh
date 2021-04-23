#!/usr/bin/env bash

cleos="cleos -u http://eosio:8000 --wallet-url http://keosd:6666"
# cleos="cleos -u http://127.0.0.1:8000 --wallet-url http://127.0.0.1:6666"

# compile custom contract
# $1 is where custom contract is
function compile_contract() {
    # generate wasm file, abi file
    eosio-cpp $1.cpp -o $1.wasm
}

# recompile custom contract
# $1 is where custom contract is
function recompile_contract() {
    eosio-cpp -abigen -o $1.wasm $1.cpp
}

# deploy custom contract
# $1 is account name(which is created with 'system newaccount' and give it 'ram'),
# $2 is where custom contract is
function deploy_contract() {
    # set wasm
    $cleos set code $1 $2.wasm -p $1@active
    # set abi
    $cleos set abi $1 $2.abi -p $1@active
}