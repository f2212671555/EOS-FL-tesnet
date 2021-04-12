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

function deploy_system_contracts () {
  echo "Deploy eosio.token"
  $cleos set contract eosio.token $EOSIO_CONTRACTS_DIRECTORY/eosio.token

  # echo "Deploy eosio.msig"
  $cleos set contract eosio.msig $EOSIO_CONTRACTS_DIRECTORY/eosio.msig

  # echo "Create and allocate the EOS currency"
  $cleos push action eosio.token create '[ "eosio", "10000000000.0000 SYS"]' -p eosio.token@active
  $cleos push action eosio.token issue '[ "eosio", "10000000000.0000 SYS", "initial supply" ]' -p eosio@active

  # Activate PREACTIVATE_FEATURE(otherwise, Deploy eosio.system will error, show 'env.preactivate_feature unresolveable'),add 'plugin = eosio::producer_api_plugin' in config.ini
  # I want to use util check http result.
  echo "Activate PREACTIVATE_FEATURE"
  curl -X POST eosio:8888/v1/producer/schedule_protocol_feature_activations -d '{"protocol_features_to_activate": ["0ec7e080177b2c02b278d5088611686b49d739925a92d9bfcacd7fc6b74053bd"]}' | jq

  result=1
  set +e;
  while [ "$result" -ne "0" ]; do
    echo "Setting old eosio.bios contract...";
    $cleos set contract eosio \
      $EOSIO_OLD_CONTRACTS_DIRECTORY/eosio.bios/ \
      -x 1000;
    result=$?
    [[ "$result" -ne "0" ]] && echo "Failed, trying again";
  done
  set -e;

  activate_features

  set +e;
  result=1;
  while [ "$result" -ne "0" ]; do
    echo "Setting latest eosio.bios contract...";
    $cleos set contract eosio \
      $EOSIO_CONTRACTS_DIRECTORY/eosio.bios/ \
      -p eosio \
      -x 1000;
    result=$?
    [[ "$result" -ne "0" ]] && echo "Failed, trying again";
  done
  set -e;

  # result=1
  # set +e;
  # while [ "$result" -ne "0" ]; do
  #   echo "Setting old eosio.system contract...";
  #   $cleos set contract eosio \
  #     $EOSIO_OLD_CONTRACTS_DIRECTORY/eosio.system/ \
  #     -x 1000;
  #   result=$?
  #   [[ "$result" -ne "0" ]] && echo "Failed, trying again";
  # done
  # set -e;

  # set +e;
  # result=1;
  # while [ "$result" -ne "0" ]; do
  #   echo "Setting latest eosio.system contract...";
  #   $cleos set contract eosio \
  #     $EOSIO_CONTRACTS_DIRECTORY/eosio.system/ \
  #     -p eosio \
  #     -x 1000;
  #   result=$?
  #   [[ "$result" -ne "0" ]] && echo "Failed, trying again";
  # done
  # set -e;

  echo "Make eosio.msig privileged"
  $cleos push action eosio setpriv '["eosio.msig", 1]' -p eosio@active
}

function activate_features() {
  # GET_SENDER
  $cleos push action eosio activate '["f0af56d2c5a48d60a4a5b5c903edfb7db3a736a94ed589d0b797df33ff9d3e1d"]' -p eosio

  # FORWARD_SETCODE
  $cleos push action eosio activate '["2652f5f96006294109b3dd0bbde63693f55324af452b799ee137a81a905eed25"]' -p eosio

  # ONLY_BILL_FIRST_AUTHORIZER
  $cleos push action eosio activate '["8ba52fe7a3956c5cd3a656a3174b931d3bb2abb45578befc59f283ecd816a405"]' -p eosio

  # RESTRICT_ACTION_TO_SELF
  $cleos push action eosio activate '["ad9e3d8f650687709fd68f4b90b41f7d825a365b02c23a636cef88ac2ac00c43"]' -p eosio

  # DISALLOW_EMPTY_PRODUCER_SCHEDULE
  $cleos push action eosio activate '["68dcaa34c0517d19666e6b33add67351d8c5f69e999ca1e37931bc410a297428"]' -p eosio

  # FIX_LINKAUTH_RESTRICTION
  $cleos push action eosio activate '["e0fb64b1085cc5538970158d05a009c24e276fb94e1a0bf6a528b48fbc4ff526"]' -p eosio

  # REPLACE_DEFERRED
  $cleos push action eosio activate '["ef43112c6543b88db2283a2e077278c315ae2c84719a8b25f25cc88565fbea99"]' -p eosio

  # NO_DUPLICATE_DEFERRED_ID
  $cleos push action eosio activate '["4a90c00d55454dc5b059055ca213579c6ea856967712a56017487886a4d4cc0f"]' -p eosio

  # ONLY_LINK_TO_EXISTING_PERMISSION
  $cleos push action eosio activate '["1a99a59d87e06e09ec5b028a9cbb7749b4a5ad8819004365d02dc4379a8b7241"]' -p eosio

  # RAM_RESTRICTIONS
  $cleos push action eosio activate '["4e7bf348da00a945489b2a681749eb56f5de00b900014e137ddae39f48f69d67"]' -p eosio

  # WEBAUTHN_KEY
  $cleos push action eosio activate '["4fca8bd82bbd181e714e283f83e1b45d95ca5af40fb89ad3977b653c448f78c2"]' -p eosio

  # WTMSIG_BLOCK_SIGNATURES
  $cleos push action eosio activate '["299dcb6af692324b899b39f16d5a530a33062804e41f09dc97e9f156b4476707"]' -p eosio

  sleep 2;
}

# Make sure nodeos is running in the docker container
sleep 5s
until curl eosio:8888/v1/chain/get_info
do
  sleep 1s
done

# Setup wallet and import the producer key
# create_wallet
# import_private_key 5KQwrPbwdL6PhXujxW37FSSQZ1JiwsST4cqQzDeyXtP79zkvFD3

# Initialize chain
# create_eosio_accounts
# compile_system_contracts
deploy_system_contracts