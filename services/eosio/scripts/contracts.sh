#!/usr/bin/env bash

cleos="cleos -u http://127.0.0.1:8000 --wallet-url http://127.0.0.1:6666"

# deploy custom contracts
# $1 is account name(which is created with 'system newaccount' and give it 'ram'),
# $2 is contract name
function deploy() {
    # set wasm
    $cleos set code $1 $2.wasm -p $1@active
    # set abi
    $cleos set abi $1 $2.abi -p $1@active
}