#!/usr/bin/env bash

# cleos="cleos -u http://eosio:8000 --wallet-url http://keosd:6666"
cleos="cleos -u http://127.0.0.1:8000 --wallet-url http://127.0.0.1:6666"

# ----------------------  wallet ----------------------  
function unlock_wallet () {
  echo "Unlocking default wallet..."
  $cleos wallet unlock --password $(cat $CONFIG_DIR/keys/wallet_password.txt)
  sleep .5
}

# Creates the default wallet and stores the password on a file
function create_wallet () {
  echo "Creating default wallet ..."
  local WALLET_PASSWORD=$($cleos wallet create --to-console | awk 'FNR > 3 { print $1 }' | tr -d '"')
  if [ "$WALLET_PASSWORD" = "" ]
  then
    echo "create_wallet Fail"
  else
    echo "create_wallet Success"
    echo $WALLET_PASSWORD > "$CONFIG_DIR"/keys/wallet_password.txt
  fi
  sleep .5
}

# Delete the default wallet
function delete_wallet () {
  echo "Delete default wallet ..."
  # delete wallet folder
  rm -rf $WALLET_DIR
  # delete wallet password
  rm -f $CONFIG_DIR/keys/wallet_password.txt
  sleep .5
}

# ----------------------  wallet ---------------------- 

# ----------------------  key ---------------------- 
# Helper function to import private key into the eoslocal wallet
function import_private_key () {
  $cleos wallet import --private-key $1
}

# ----------------------  key ---------------------- 

# ----------------------  account ---------------------- 
# Creates an eos account with 100 SYS
function create_eos_account () {
  # $cleos system newaccount eosio --transfer $1 $2 $2 --stake-net '1 SYS' --stake-cpu '1 EOS' --buy-ram '1 SYS'
  $cleos create account eosio $1 $2 $2
}
# ----------------------  account ---------------------

# ----------------------  node ---------------------
# start $1th node, $1 is node index, $2 is node account name, 
# $3 is node account pub key, $4 is node pvt key 
function start_node () {
    # nodes folder
    local dir=$NODE_DIR/$(printf "%02d-%s" $1 $2)
    # rm and mkdir $1th node folder
    rm -rf $dir
    mkdir -p $dir
    # generate this node's p2p-peer-address
    local p2p_address=""
    for i in $(seq 0 $1);
    do 
        ((port=$FIRST_P2P_PORT+$i))
        p2p_address+=$(printf " --p2p-peer-address localhost:%d" $port)
    done

    # give genesis node 2 plugins
    if (( $1==0 ));
    then
        p2p_address+=" --plugin eosio::history_plugin --plugin eosio::history_api_plugin"
    fi

    arguments=" --max-irreversible-block-age -1"
    arguments+=" --max-transaction-time=1000"
    arguments+=" --contracts-console"
    arguments+=" --genesis-json $GENESIS_DIR"
    arguments+=" --blocks-dir $dir/blocks"
    arguments+=" --config-dir $dir"
    arguments+=" --data-dir $dir"
    arguments+=" --chain-state-db-size-mb 1024"
    arguments+=" --http-server-address 127.0.0.1:`expr $HTTP_SERVER_PORT + $1`"
    arguments+=" --p2p-listen-endpoint 127.0.0.1:`expr $FIRST_P2P_PORT + $1`"
    arguments+=" --max-clients $MAX_CLIENTS"
    arguments+=" --p2p-max-nodes-per-host $MAX_CLIENTS"
    arguments+=" --enable-stale-production"
    arguments+=" --producer-name $2"
    arguments+=" --private-key '["$3","$4"]'"
    arguments+=" --plugin eosio::http_plugin"
    arguments+=" --plugin eosio::chain_api_plugin"
    arguments+=" --plugin eosio::chain_plugin"
    arguments+=" --plugin eosio::producer_api_plugin"
    arguments+=" --plugin eosio::producer_plugin"
    arguments+=$p2p_address

    local cmd=$cleos$arguments
    # save what cmd you run to cmd.txt in this node folder
    echo $cmd >> $dir/cmd.txt
    # run this node
    cmd
}

# ----------------------  node ---------------------

# ----------------------  custom wallet ---------------------
# used in init_chain.sh
# create producers and users account
function create_accounts(){

    # create producers account
    # set 1th to producer
    # set 2th to 4th to account
    for i in {1..4};
    do
        local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json)
        local pub=$(jq -c ".[$i].pub" $(dirname $0)/accounts.json)
        create_eos_account $name $pub
    done
}

# ----------------------  custom wallet ---------------------

# ----------------------  custom key ---------------------
# import genesis, producers and users private key
function import_keys(){
    # import genesis(0th), producers(1th), users(2th-4th) private key
    for i in {0..4};
    do
        local pvt=$(jq -c ".[$i].pvt" $(dirname $0)/accounts.json)
        import_private_key $pvt
    done
}

# ----------------------  custom key ---------------------


# ----------------------  custom account ---------------------

# ----------------------  custom account ---------------------
# ----------------------  utils ---------------------

# ----------------------  utils ---------------------