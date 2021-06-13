#!/usr/bin/env bash

cleos="cleos -u http://eosio:8000 --wallet-url http://keosd:6666"
# cleos="cleos -u http://127.0.0.1:8000 --wallet-url http://127.0.0.1:6666"

contract_account=$(jq -c ".[0].name" $(dirname $0)/../../scripts/contract_accounts.json | tr -d '"')
echo $contract_account

# save local model as model.pth
# python3 -c 'import model; model.save_model()'
# upload model to ipfs
hash=$(python3 -c 'import model; model.upload_model_to_ipfs()')
echo $hash
# create a task, let trainers train your model.
trainer_num=3
$cleos push action $contract_account enroll "[producer111a, $trainer_num, $hash]" -p producer111a@active

# upload ipfs hash to blockchain


# result=1
# set +e;
# while [ "$result" -ne "0" ]; do
#     echo "System New Account..."
#     $cleos system newaccount --stake-net "50.0000 OUO" --stake-cpu "50.0000 OUO" --buy-ram-kbytes 4096 eosio $name $pub -p eosio
#     result=$?
#     [[ "$result" -ne "0" ]] && echo "Failed, trying again";
# done

# $cleos wallet import --private-key $pvt
# set -e;