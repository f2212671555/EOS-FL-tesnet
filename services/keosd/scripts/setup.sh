#!/usr/bin/env bash

source $(dirname $0)/helpers.sh

echo "stop keosd..."
stop_keosd

echo "delete wallet dir..."
delete_wallet_dir

echo "run keosd background..."
run_keosd_background