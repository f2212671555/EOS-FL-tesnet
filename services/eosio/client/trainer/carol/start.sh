#!/usr/bin/env bash

cleos="cleos -u http://eosio:8000 --wallet-url http://keosd:6666"
# cleos="cleos -u http://127.0.0.1:8000 --wallet-url http://127.0.0.1:6666"

contract_account=$(jq -c ".[0].name" $(dirname $0)/../../../scripts/contract_accounts.json | tr -d '"')
echo $contract_account

# get model which model owner uploaded from blockchain
# check task0
result=1
while [ "$result" -ne "0" ]; do
    echo "Check New Task..."
    res=$($cleos get table $contract_account $contract_account tasks)
    for k in $(jq '.rows | keys | .[]' <<< "$res"); do
        row=$(jq -r ".rows[$k]" <<< "$res")
        id=$(jq -r '.id' <<< "$row")
        if [ "$id" == "0" ]  # check task0
        then
            status=$(jq -r '.status' <<< "$row")
            echo $status
            # check task0 status
            if [ "$status" == "WAITING" ] # this task is waiting for people upload their params.
            then
                model_hash=$(jq -r '.hash' <<< "$row")
                echo $model_hash
                # download model with hash from ipfs and start to train
                python3 train.py $model_hash
                # upload params to ipfs
                params_hash=$(python3 -c 'import model; model.upload_params_to_ipfs()')
                echo $params_hash

                # store model param hash to blockchain
                # 0 is mean task0
                $cleos push action $contract_account upload "[useraaaaaaac, 0, $params_hash]" -p useraaaaaaac@active
            elif [ "$status" == "CONVERGENT" ] # means model is convergent, this task is finished.
            then
                result=0 # quit this check task loop
            # else : status == AGGREGATING, model is aggregating, do nothing, just wait for next round.
            fi
            break
        fi
    done
done

echo "This Task is Finished~"


