#!/usr/bin/env bash

source $(dirname $0)/helpers.sh

echo "stop keosd..."
stop_keosd

echo "run keosd background..."
run_keosd_background