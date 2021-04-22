#!/usr/bin/env bash

# cleos="cleos -u http://eosio:8000 --wallet-url http://keosd:6666"
cleos="cleos -u http://127.0.0.1:8000 --wallet-url http://127.0.0.1:6666"
nodeos="nodeos -e -p eosio"

# ----------------------  wallet ---------------------- 
# unlock target wallet
# $1 is index 
function unlock_wallet () {
  local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json | tr -d '"')
  echo "Unlocking $1 wallet..."
  $cleos wallet unlock --password $(cat $CONFIG_DIR/keys/`$name`_wallet_password.txt)
  sleep .5
}

# unlock all wallets
# $1 is index 
function unlock_wallets () {
  for i in {0..4};
  do
    unlock_wallet $1
    echo "Unlocking $1 wallet..."
  done
  sleep .5
}

# Creates the default wallet and stores the password on a file
function create_wallet () {
  echo "Creating $1 wallet ..."
  local WALLET_PASSWORD=""
  # if $1 is eosio(genesis) create default wallet
  if [ "$1" = "eosio" ]
  then
    WALLET_PASSWORD=$($cleos wallet create --to-console | awk 'FNR > 3 { print $1 }' | tr -d '"')
  else
  WALLET_PASSWORD=$($cleos wallet create -n $1 --to-console | awk 'FNR > 3 { print $1 }' | tr -d '"')
  fi
  
  if [ "$WALLET_PASSWORD" = "" ]
  then
    echo "$1 create_wallet Fail"
  else
    echo "$1 create_wallet Success"
    echo $WALLET_PASSWORD > "$CONFIG_DIR"/keys/$1_wallet_password.txt
  fi
  sleep .5
}

function create_wallets () {
  # create 1th to 4th users wallet
  for i in {1..4};
    do
        local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json | tr -d '"')
        create_wallet $name
    done
}

# Delete target wallet
# $1 is index
function delete_wallet () {
  local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json | tr -d '"')
  echo "Delete $1 wallet ..."
  # delete wallet folder
  rm -f $WALLET_DIR/$name.wallet
  # delete wallet password
  rm -f $CONFIG_DIR/keys/`$name`_wallet_password.txt
  sleep .5
}

# Delete all wallets
function delete_wallets () {
  echo "Delete all wallet ..."
  # delete wallet folder
  rm -rf $WALLET_DIR
  # delete wallet password
  rm -f $CONFIG_DIR/keys/*.txt
  sleep .5
}

# ----------------------  wallet ---------------------- 

# ----------------------  key ---------------------- 
# Helper function to import private key into the eoslocal wallet
# $1 is pvt, $2 is name
function import_private_key () {
  $cleos wallet import --private-key $1
  # if [ "$2" = "eosio" ];
  # then
  #   $cleos wallet import --private-key $1
  # else
  #   # $cleos wallet import --private-key $1 -n $2
  # fi
}

# ----------------------  key ---------------------- 

# ----------------------  account ---------------------- 
# Creates an eos account with 100 SYS
function create_eos_account () {
  $cleos system newaccount eosio --transfer $1 $2 $2 --stake-net '1000.000 OUO' --stake-cpu '100.000 OUO' --buy-ram '1000.000 OUO'
  # $cleos create account eosio $1 $2 $2
}
# ----------------------  account ---------------------

# ----------------------  node ---------------------
# generate config
# $1 is node index
function generate_nodes_config () {
    # config nodes folder
    local dir=$CONFIG_DIR/nodes/node$1
    # rm and mkdir $1th node config folder
    rm -rf $dir
    mkdir -p $dir
    # # recreate config.ini
    rm -rf $dir/config.ini
    touch $dir/config.ini
    # config nodes folder
    local log_dir=$LOGS_DIR/nodes/node$1
    # rm and mkdir $1th node log folder
    rm -rf $log_dir
    mkdir -p $log_dir
    # recreate log
    rm -rf $log_dir/nodeos.log
    touch $log_dir/nodeos.log
    local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json | tr -d '"')
    local pub=$(jq -c ".[$i].pub" $(dirname $0)/accounts.json | tr -d '"')
    local pvt=$(jq -c ".[$i].pvt" $(dirname $0)/accounts.json | tr -d '"')

    # generate this node's p2p-peer-address
    local p2p_address=""
    for i in $(seq 0 $1);
    do
        ((port=$FIRST_P2P_PORT+$i))
        echo "p2p-peer-address = localhost:$port" >> $dir/config.ini
    done

    echo "max-irreversible-block-age = -1" >> $dir/config.ini
    echo "max-transaction-time = 1000" >> $dir/config.ini
    echo "contracts-console = true " >> $dir/config.ini
    echo "chain-state-db-size-mb = 1024" >> $dir/config.ini
    echo "http-server-address = 0.0.0.0:`expr $HTTP_SERVER_PORT + $1`" >> $dir/config.ini
    echo "p2p-listen-endpoint = 127.0.0.1:`expr $FIRST_P2P_PORT + $1`" >> $dir/config.ini

    echo "max-clients = $MAX_CLIENTS" >> $dir/config.ini
    echo "p2p-max-nodes-per-host = $MAX_CLIENTS" >> $dir/config.ini
    echo "enable-stale-production = true" >> $dir/config.ini
    echo "producer-name = $name" >> $dir/config.ini
    echo "signature-provider = $pub=KEY:$pvt" >> $dir/config.ini
    echo "plugin = eosio::http_plugin" >> $dir/config.ini
    echo "plugin = eosio::chain_api_plugin" >> $dir/config.ini
    echo "plugin = eosio::chain_plugin" >> $dir/config.ini
    echo "plugin = eosio::producer_api_plugin" >> $dir/config.ini
    echo "plugin = eosio::producer_plugin" >> $dir/config.ini

    # give genesis node 2 plugins
    if (( $1==0 ));
    then
        echo "plugin = eosio::history_plugin" >> $dir/config.ini
        echo "plugin = eosio::history_api_plugin" >> $dir/config.ini
    fi

    echo "Node $1 is inited."
}

# start $1th node, $1 is node index
function start_node () {
    # nodes folder
    local dir=$CONFIG_DIR/nodes/node$1
    local log_dir=/opt/application/logs
    # run node
    $nodeos \
          --genesis-json $GENESIS_DIR/genesis.json \
          --blocks-dir $CONFIG_DIR/nodes/node$1/blocks \
          --config-dir $CONFIG_DIR/nodes/node$1 \
          --data-dir $CONFIG_DIR/nodes/node$1 >> $LOGS_DIR/nodes/node$1/nodeos.log 2>&1 &
    echo "Node $1 is running."
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
        local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json | tr -d '"')
        local pub=$(jq -c ".[$i].pub" $(dirname $0)/accounts.json | tr -d '"')
        create_eos_account $name $pub
    done
}

# ----------------------  custom wallet ---------------------

# ----------------------  custom key ---------------------
# import genesis, producers and users private key
function import_keys(){
    # import genesis(0th), producers(1th), users(2th-4th) private key
    for i in {0..0};
    do
        local name=$(jq -c ".[$i].name" $(dirname $0)/accounts.json | tr -d '"')
        local pvt=$(jq -c ".[$i].pvt" $(dirname $0)/accounts.json | tr -d '"')
        import_private_key $pvt $name
        # import_private_key $pvt
    done
}

# ----------------------  custom key ---------------------


# ----------------------  custom account ---------------------

# ----------------------  custom account ---------------------
# ----------------------  utils ---------------------

# ----------------------  utils ---------------------