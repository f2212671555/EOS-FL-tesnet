#!/usr/bin/env bash

source $(dirname $0)/helpers.sh

# init variables
# init max client
# max client number = producers number + users number
MAX_CLIENTS=4

# get genesis info. from accounts.json
gene_name=$(jq -c '.[0].name' $(dirname $0)/accounts.json)
gene_pub=$(jq -c '.[0].pub' $(dirname $0)/accounts.json)
gene_pvt=$(jq -c '.[0].pvt' $(dirname $0)/accounts.json)

# init eosio system accounts(eosio.*)
system_accounts=('eosio.bpay' 'eosio.msig' 'eosio.names' 'eosio.ram' 'eosio.ramfee' 'eosio.saving' 'eosio.stake' 'eosio.token' 'eosio.vpay' 'eosio.rex')

# init this chain money symbol
money_symbol="OUO"
# init this chain give genesis node how much money when it is created
genesis_money_system_give="10000000000.0000"

# Kill all nodeos and keosd processes
function stepKillAll() {
    killall keosd nodeos
    sleep 1.5
}

# Start keosd, create wallet, fill with keys
function stepStartWallet() {
    # Start the default wallet
    keosd --wallet-dir $WALLET_DIR --unlock-timeout 999999999 --http-server-address=127.0.0.1:6666 --http-validate-host 0 --verbose-http-errors &
    sleep .5
    # create the default wallet
    create_wallet
    # import private key to genesis
    import_keys
}

# Start boot node(start genesis node)
function stepStartBoot() {
    # run genesis node
    # $1 is node index, $2 is account name,
    # $3 is account pub key, $4 is account pvt key.
    # node index '0' for genesis
    start_node 0 $gene_name $gene_pub $gene_pvt
    sleep 1.5
}

# Create system accounts (eosio.*)
function createSystemAccounts() {
    for i in ${!system_accounts[@]};
    do
        local system_account=${system_accounts[$i]}
        echo $cleos create account eosio $system_account $gene_pub
    done
}

# Install system contracts (token, msig)
function stepInstallSystemContracts() {
    $cleos set contract eosio.token $EOSIO_CONTRACTS_DIRECTORY/eosio.token/
    $cleos set contract eosio.msig $EOSIO_CONTRACTS_DIRECTORY/eosio.msig/
}

# Create tokens
function stepCreateTokens() {
    # init give genesis node money
    $cleos push action eosio.token create "'[$gene_name, $genesis_money_system_give $money_symbol]'" -p eosio.token
    $cleos push action eosio.token issue "'[$gene_name, $genesis_money_system_give $money_symbol, "initial supply"]'" -p eosio
    sleep 1
}

# Set system contract
function stepSetSystemContract() {
    # activate PREACTIVATE_FEATURE before installing eosio.system
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate PREACTIVATE_FEATURE..."
        curl -X POST 127.0.0.1:8000/v1/producer/schedule_protocol_feature_activations -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}'
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # install eosio.system the older version first
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Install old eosio.system contract...";
        $cleos set contract eosio $EOSIO_OLD_CONTRACTS_DIRECTORY/eosio.system/
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # activate remaining features
    # GET_SENDER
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate GET_SENDER...";
        $cleos push action eosio activate '["f0af56d2c5a48d60a4a5b5c903edfb7db3a736a94ed589d0b797df33ff9d3e1d"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # FORWARD_SETCODE
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate FORWARD_SETCODE...";
        $cleos push action eosio activate '["2652f5f96006294109b3dd0bbde63693f55324af452b799ee137a81a905eed25"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # ONLY_BILL_FIRST_AUTHORIZER
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate ONLY_BILL_FIRST_AUTHORIZER...";
        $cleos push action eosio activate '["8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # RESTRICT_ACTION_TO_SELF
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate RESTRICT_ACTION_TO_SELF...";
        $cleos push action eosio activate '["ad9e3d8f650687709fd68f4b90b41f7d825a365b02c23a636cef88ac2ac00c43"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # DISALLOW_EMPTY_PRODUCER_SCHEDULE
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate DISALLOW_EMPTY_PRODUCER_SCHEDULE...";
        $cleos push action eosio activate '["68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # FIX_LINKAUTH_RESTRICTION
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate FIX_LINKAUTH_RESTRICTION...";
        $cleos push action eosio activate '["e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # REPLACE_DEFERRED
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate REPLACE_DEFERRED...";
        $cleos push action eosio activate '["ef43112c6543b88db2283a2e077278c315ae2c84719a8b25f25cc88565fbea99"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # NO_DUPLICATE_DEFERRED_ID
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate NO_DUPLICATE_DEFERRED_ID...";
        $cleos push action eosio activate '["4a90c00d55454dc5b059055ca213579c6ea856967712a56017487886a4d4cc0f"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # ONLY_LINK_TO_EXISTING_PERMISSION
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate ONLY_LINK_TO_EXISTING_PERMISSION...";
        $cleos push action eosio activate '["1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # RAM_RESTRICTIONS
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate RAM_RESTRICTIONS...";
        $cleos push action eosio activate '["4e7bf348da00a945489b2a681749eb56f5de00b900014e137ddae39f48f69d67"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # WEBAUTHN_KEY
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate WEBAUTHN_KEY...";
        $cleos push action eosio activate '["4fca8bd82bbd181e714e283f83e1b45d95ca5af40fb89ad3977b653c448f78c2"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3

    # WTMSIG_BLOCK_SIGNATURES
    result=1
    set +e;
        while [ "$result" -ne "0" ]; do
        echo "Activate WTMSIG_BLOCK_SIGNATURES...";
        $cleos push action eosio activate '["299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707"]' -p eosio
        result=$?
        [[ "$result" -ne "0" ]] && echo "Failed, trying again";
        done
    set -e;
    sleep 3
}

# Initialiaze system contract
function stepInitSystemContract() {
    $cleos push action eosio init '[0, "'4,${money_symbol}'"]' -p eosio@active
    sleep 1
}

# Create staked accounts
function stepCreateStakedAccounts() {
    # 2th to 4th is user nodes
    for i in {2..4};
    do
        local name=$(jq ".[$i].name" $(dirname $0)/accounts.json)
        local pub=$(jq ".[$i].pub" $(dirname $0)/accounts.json)
        local pvt=$(jq ".[$i].pvt" $(dirname $0)/accounts.json)
        start_node $i $name $pub $pvt
    done
}

# Register producers
# function stepRegProducers() {

# }

# Start producers
function stepStartProducers() {
    # 1th is producers
    for i in {1..1};
    do
        local name=$(jq ".[$i].name" $(dirname $0)/accounts.json)
        local pub=$(jq ".[$i].pub" $(dirname $0)/accounts.json)
        local pvt=$(jq ".[$i].pvt" $(dirname $0)/accounts.json)
        start_node $i $name $pub $pvt
    done
}

# # Vote for producers
# function stepVote() {

# }

# # Claim rewards
# function claimRewards() {

# }

# # Proxy votes
# function stepProxyVotes() {

# }

# # Resign eosio
# function stepResign() {

# }

# # Replace system contract using msig
# function msigReplaceSystem() {

# }

# # Random transfer tokens (infinite loop)
# function stepTransfer() {

# }

# # Show tail of node's log
# function stepLog() {

# }

set_voters(){
    # set 2th to 4th key="users" in account.json to be voters
    for i in {2..4;
    do
        local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json)
        local pub=$(jq -c ".[$i].pub" $(dirname $0)/accounts.json)
        sleep 0.1
        $cleos system newaccount --stake-net "50.0000 $money_symbol" --stake-cpu "50.0000 $money_symbol" --buy-ram-kbytes 4096 eosio ${name} ${pub} -p eosio
        sleep 0.1
        $cleos transfer eosio ${name} "21000000.0000 $money_symbol" "Give you 21000000 $money_symbol"
        echo "Node $name set to voters"
    done

}

set_producers(){
    # set 1th to "producers" in account.json to be producer
    for i in {1..1};
    do
        local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json)
        local pub=$(jq -c ".[$i].pub" $(dirname $0)/accounts.json)
        sleep 0.1
        $cleos system newaccount --stake-net "50.0000 $money_symbol" --stake-cpu "50.0000 $money_symbol" --buy-ram-kbytes 4096 eosio ${name} ${pub} -p eosio
        sleep 0.1
        $cleos transfer eosio ${name} "100.0000 $money_symbol" "Give you 100 $money_symbol"
        sleep 0.1
        $cleos system regproducer ${name} ${pub} http://localhost:`expr 9000 + $i`
        echo "Node $name set to producers"
    done
}

run_vote(){
    # let 2th to 4th to "voters" in account.json which are setted as voters to vote
    for i in {2..4};
    do
        local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json)
        local pub=$(jq -c ".[$i].pub" $(dirname $0)/accounts.json)
        sleep 0.1
        $cleos system delegatebw ${name} ${name} "10000000.0000 $money_symbol" "10000000.0000 $money_symbol"
        sleep 0.1
        #$cleos system voteproducer prods ${name} 
        # eval $(python3 EOS-lab-testnet/eosvote.py)
        echo
    done 
}