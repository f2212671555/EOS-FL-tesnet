#!/usr/bin/env bash

cleos="cleos -u http://eosio:8000 --wallet-url http://keosd:6666"
# cleos="cleos -u http://127.0.0.1:8000 --wallet-url http://127.0.0.1:6666"

# compile custom contract
# $1 is the custom contract folder,
# $2 is custom contract file name
function compile_contract() {
    # generate wasm file, abi file
    eosio-cpp $CONTRACTS_DIR/$1/$2.cpp -o $CONTRACTS_DIR/$1/$2.wasm
}

# recompile custom contract
# $1 is the custom contract folder,
# $2 is custom contract file name
function recompile_contract() {
    eosio-cpp -abigen -o $CONTRACTS_DIR/$1/$2.wasm $CONTRACTS_DIR/$1/$2.cpp
}

# deploy custom contract
# $1 is account name(which is created with 'system newaccount' and give it 'ram'),
# $2 is the custom contract folder,
# $3 is custom contract file name
function deploy_contract() {
    # set wasm
    $cleos set code $1 $CONTRACTS_DIR/$2/$3.wasm -p $1@active
    # set abi
    $cleos set abi $1 $CONTRACTS_DIR/$2/$3.abi -p $1@active
}
CONTRACTS_DIR=/opt/application/contracts
# compile_contract todo todo
# deploy_contract useraaaaaaaa todo todo
# $cleos push action useraaaaaaaa create '["useraaaaaaaa", "Eat Dinner"]' -p useraaaaaaaa@active
# $cleos push action useraaaaaaaa update '[6, "Eating"]' -p useraaaaaaaa@active
# $cleos push action useraaaaaaaa remove '[0]' -p useraaaaaaaa@active
# $cleos get table useraaaaaaaa useraaaaaaaa tasks