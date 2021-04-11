#!/usr/bin/env bash

# Throws error when using unset variable
set -ux

# Import helper functions
source $(dirname $0)/helpers.sh

# Helper function to create system accounts
function create_system_account () {
  $cleos create account eosio $1 $2
}

# Creates eosio system accounts
# https://developers.eos.io/eosio-nodeos/docs/bios-boot-sequence#section-step-3-create-important-system-accounts
function create_eosio_accounts () {
  EOSIO_PVTKEY="5KAVVPzPZnbAx8dHz6UWVPFDVFtU1P5ncUzwHGQFuTxnEbdHJL4"
  EOSIO_PUBKEY="EOS84BLRbGbFahNJEpnnJHYCoW9QPbQEk2iHsHGGS6qcVUq9HhutG"

  import_private_key $EOSIO_PVTKEY

  create_system_account eosio.bpay $EOSIO_PUBKEY
  create_system_account eosio.msig $EOSIO_PUBKEY
  create_system_account eosio.names $EOSIO_PUBKEY
  create_system_account eosio.ram $EOSIO_PUBKEY
  create_system_account eosio.ramfee $EOSIO_PUBKEY
  create_system_account eosio.saving $EOSIO_PUBKEY
  create_system_account eosio.stake $EOSIO_PUBKEY
  create_system_account eosio.token $EOSIO_PUBKEY
  create_system_account eosio.vpay $EOSIO_PUBKEY
}

function compile_system_contracts () {
  cd $SYS_CONTRACTS_DIR
  git clone --recursive https://github.com/EOSIO/eosio.contracts.git --branch develop
  cd $SYS_CONTRACTS_DIR/eosio.contracts
  rm -fr build
  mkdir build
  cd build
  cmake ..
  make -j4
}

function deploy_system_contracts () {
  echo "Deploy eosio.token"
  $cleos set contract eosio.token $SYS_CONTRACTS_DIR/eosio.contracts/build/contracts/eosio.token

  echo "Deploy eosio.msig"
  $cleos set contract eosio.msig $SYS_CONTRACTS_DIR/eosio.contracts/build/contracts/eosio.msig

  echo "Create and allocate the SYS currency"  # https://github.com/EOSIO/eos/issues/3996
  $cleos push action eosio.token create '[ "eosio", "10000000000.0000 SYS"]' -p eosio.token@active
  $cleos push action eosio.token issue '[ "eosio", "10000000000.0000 SYS", "initial supply" ]' -p eosio@active

  echo "Create and allocate the EOS currency"
  $cleos push action eosio.token create '[ "eosio", "10000000000.0000 EOS"]' -p eosio.token@active
  $cleos push action eosio.token issue '[ "eosio", "10000000000.0000 EOS", "initial supply" ]' -p eosio@active

  # Activate PREACTIVATE_FEATURE(otherwise, Deploy eosio.system will error, show 'env.preactivate_feature unresolveable'),add 'plugin = eosio::producer_api_plugin' in config.ini
  # I want to use util check http result.
  echo "Activate PREACTIVATE_FEATURE"
  curl -X POST eosio:8888/v1/producer/schedule_protocol_feature_activations -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}' | jq
  
  # Before activating WTMSIG_BLOCK_SIGNATURES
  echo "Deploy eosio.boot"
  $cleos set contract eosio $SYS_CONTRACTS_DIR/eosio.contracts/build/contracts/eosio.boot

  # Activate WTMSIG_BLOCK_SIGNATURES
  echo "Activate WTMSIG_BLOCK_SIGNATURES"
  $cleos push transaction '{"delay_sec":0,"max_cpu_usage_ms":0,"actions":[{"account":"eosio","name":"activate","data":{"feature_digest":"299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707"},"authorization":[{"actor":"eosio","permission":"active"}]}]}'
  sleep 0.5
  # docker ram recommend 8g
  echo "Deploy eosio.system"
  $cleos set contract eosio $SYS_CONTRACTS_DIR/eosio.contracts/build/contracts/eosio.system

  echo "Init system with EOS symbol"
  $cleos push action eosio init '["0", "4,EOS"]' -p eosio@active

  echo "Deploy eosio.bios"
  $cleos set contract eosio $SYS_CONTRACTS_DIR/eosio.contracts/build/contracts/eosio.bios

  echo "Make eosio.msig privileged"
  $cleos push action eosio setpriv '["eosio.msig", 1]' -p eosio@active
}

# Make sure nodeos is running in the docker container
sleep 5s
until curl eosio:8888/v1/chain/get_info
do
  sleep 1s
done

# Setup wallet and import the producer key
create_wallet
import_private_key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

# Initialize chain
create_eosio_accounts
compile_system_contracts
deploy_system_contracts