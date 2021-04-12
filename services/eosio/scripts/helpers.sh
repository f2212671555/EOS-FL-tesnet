#!/usr/bin/env bash

# Throws error when using unset variable
set -ux

# Alias cleos with endpoint param to avoid repetition
# We use as host here because that service name configured in docker-compose.yml
cleos="cleos -u http://eosio:8888 --wallet-url http://keosd:8901"

# Unlocks the default wallet and waits .5 seconds
function unlock_wallet () {
  echo "Unlocking defaault wallet..."
  $cleos wallet unlock --password $(cat $CONFIG_DIR/keys/wallet_password.txt)
  sleep .5
}

# Creates the default wallet and stores the password on a file
function create_wallet () {
  echo "Creating default wallet ..."
  WALLET_PASSWORD=$($cleos wallet create --to-console | awk 'FNR > 3 { print $1 }' | tr -d '"')
  if [ "$WALLET_PASSWORD" = "" ]
  then
    echo "create_wallet Fail"
  else
    echo "create_wallet Success"
    echo $WALLET_PASSWORD > "$CONFIG_DIR"/keys/wallet_password.txt
  fi
  sleep .5
}

# Helper function to import private key into the eoslocal wallet
function import_private_key () {
  $cleos wallet import --private-key $1
}

# Creates an eos account with 100 EOS
function create_eos_account () {
  # $cleos system newaccount eosio --transfer $1 $2 $2 --stake-net '1 SYS' --stake-cpu '1 EOS' --buy-ram '1 SYS'
  $cleos create account eosio $1 $2 $2
  $cleos transfer eosio $1 '100 SYS' -p eosio
}