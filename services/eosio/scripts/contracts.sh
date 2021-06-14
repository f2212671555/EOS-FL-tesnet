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


name=$(jq -c ".[0].name" $(dirname $0)/contract_accounts.json | tr -d '"')
pub=$(jq -c ".[0].pub" $(dirname $0)/contract_accounts.json | tr -d '"')
pvt=$(jq -c ".[0].pvt" $(dirname $0)/contract_accounts.json | tr -d '"')
contract_account=$name

function create_contract_account() {

    result=1
    set +e;
    while [ "$result" -ne "0" ]; do
        echo "System New Account..."
        $cleos system newaccount --stake-net "50.0000 OUO" --stake-cpu "50.0000 OUO" --buy-ram-kbytes 4096 eosio $name $pub -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
    done

    $cleos wallet import --private-key $pvt
    set -e;

    # $cleos wallet keys
    
}


create_contract_account

compile_contract model model
deploy_contract $contract_account model model


#----test

# $cleos push action $contract_account enroll '["useraaaaaaaa", 3, "Eat Dinner OAO"]' -p useraaaaaaaa@active
# $cleos push action $contract_account update '[1, "DOINGGG"]' -p useraaaaaaaa@active
# $cleos push action $contract_account upload '["producer111a", 1, "DOING"]' -p producer111a@active
# $cleos push action $contract_account record '["useraaaaaaaa", 1, 1, "DOING", "50"]' -p useraaaaaaaa@active
# $cleos push action $contract_account remove '[1]' -p useraaaaaaaa@active

# account -> The account who owns the table where the smart contract was deployed
# scope -> The scope within the contract in which the table is found
$cleos get table $contract_account $contract_account tasks