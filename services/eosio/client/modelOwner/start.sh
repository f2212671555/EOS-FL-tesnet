#!/usr/bin/env bash

cleos="cleos -u http://eosio:8000 --wallet-url http://keosd:6666"
# cleos="cleos -u http://127.0.0.1:8000 --wallet-url http://127.0.0.1:6666"

contract_account=$(jq -c ".[0].name" $(dirname $0)/../../scripts/contract_accounts.json | tr -d '"')
echo $contract_account

# save local model as model.pth
python3 -c 'import model; model.save_model()'
# upload model to ipfs
model_hash=$(python3 -c 'import model; model.upload_model_to_ipfs()')
# echo $model_hash
# create a task, let trainers train your model.
trainer_num=3
convergent=97.3
$cleos push action $contract_account enroll "[producer111a, $trainer_num, $model_hash]" -p producer111a@active

# upload ipfs hash to blockchain
# check task0
# download model param from ipfs
# aggregate model param
result=1
while [ "$result" -ne "0" ]; do
    echo "Check This Task's status..."
    res=$($cleos get table $contract_account $contract_account tasks)
    for k in $(jq '.rows | keys | .[]' <<< "$res"); do
        row=$(jq -r ".rows[$k]" <<< "$res")
        id=$(jq -r '.id' <<< "$row")
        if [ "$id" == "0" ]  # check task0
        then
            status=$(jq -r '.status' <<< "$row")
            echo $status
            if [ "$status" == "AGGREGATING" ]  # check task0 status time to let model aggregate
            then
                array=()
                for j in $(jq '.modelparam | keys | .[]' <<< "$row"); do
                    modelparam=$(jq -r ".modelparam[$j]" <<< "$row")
                    param_hash=$(jq -r '.hash' <<< "$modelparam")
                    echo $param_hash
                    # download model param from ipfs
                    python3 -c 'import model; model.load_model_param_from_ipfs('$param_hash')'
                    array+=("$param_hash")
                done
                echo ${array[@]}
                # pass convergent and model params
                # aggregate model param and assign to model
                python3 train.py $convergent ${array[@]}
                convergent=$(jq -c ".convergent" $(dirname $0)/convergent.json | tr -d '"')
                if [ "$convergent" == true ] # if model is convergent
                then
                    # call smart contract update table status, let others know this task is finished
                    $cleos push action $contract_account convergent "[0]" -p producer111a@active
                    result=0 # quit this check task loop
                else
                    #upload newmodel.pth to ipfs
                    new_model_hash=$(python3 -c 'import model; model.upload_model_to_ipfs()')
                    $cleos push action $contract_account update "[0, $new_model_hash]" -p producer111a@active
                fi
                break
            fi
        fi
    done
done
echo "Your Task is Finished!"