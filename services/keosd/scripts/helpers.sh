#!/usr/bin/env bash

# kill keosd
function stop_keosd() {
    pkill keosd
}

# recreate wallet folder
function delete_wallet_dir() {
    rm -rf $WALLET_DIR
    mkdir -p $WALLET_DIR
}

# run keosd in background
function run_keosd_background() {
    # recreate log
    rm -rf $LOGS_DIR/keosd.log
    touch $LOGS_DIR/keosd.log
    # run keosd in background
    keosd --wallet-dir $WALLET_DIR \
        --unlock-timeout 999999999 --http-server-address=$HTTP_SERVER_ADDRESS \
        --http-validate-host 0 --verbose-http-errors >> $LOGS_DIR/keosd.log 2>&1 &
}

# run keosd
function run_keosd_background() {

    keosd --wallet-dir $WALLET_DIR \
        --unlock-timeout 999999999 --http-server-address=$HTTP_SERVER_ADDRESS \
        --http-validate-host 0 --verbose-http-errors
}