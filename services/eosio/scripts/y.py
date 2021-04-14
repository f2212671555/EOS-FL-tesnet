import argparse
import os
import random
import re
import subprocess
import sys
import time

maxClients = 31
def startNode(nodeIndex, account):
    dir = './nodes/' + ('%02d-' % nodeIndex) + account['name'] + '/'

    otherOpts = ''.join(list(map(lambda i: '    --p2p-peer-address localhost:' + str(9000 + i), range(nodeIndex))))
    if not nodeIndex: otherOpts += (
        '    --plugin eosio::history_plugin'
        '    --plugin eosio::history_api_plugin'
    )
    cmd = (
        'args.nodeos'
        '    --max-irreversible-block-age -1'
        '    --max-transaction-time=1000'
        '    --contracts-console'
        '    --chain-state-db-size-mb 1024'
        '    --http-server-address 127.0.0.1:' + str(8000 + nodeIndex) +
        '    --p2p-listen-endpoint 127.0.0.1:' + str(9000 + nodeIndex) +
        '    --max-clients ' + str(maxClients) +
        '    --p2p-max-nodes-per-host ' + str(maxClients) +
        '    --enable-stale-production'
        '    --producer-name ' + account['name'] +
        '    --private-key \'["' + account['pub'] + '","' + account['pvt'] + '"]\''
        '    --plugin eosio::http_plugin'
        '    --plugin eosio::chain_api_plugin'
        '    --plugin eosio::chain_plugin'
        '    --plugin eosio::producer_api_plugin'
        '    --plugin eosio::producer_plugin' +
        otherOpts)
    print(dir)
    # print(cmd)

startNode(3, {'name': 'eosio', 'pvt': 'args.private_key', 'pub': 'args.public_key'})
# print(dir)
# ./nodes/03-eosio/

# print(cmd)
# args.nodeos    --max-irreversible-block-age -1    
# --max-transaction-time=1000    --contracts-console    
# --chain-state-db-size-mb 1024    --http-server-address 127.0.0.1:8003    
# --p2p-listen-endpoint 127.0.0.1:9003    --max-clients 31    
# --p2p-max-nodes-per-host 31    --enable-stale-production    
# --producer-name eosio    --private-key '["args.public_key","args.private_key"]'    
# --plugin eosio::http_plugin    --plugin eosio::chain_api_plugin    
# --plugin eosio::chain_plugin    --plugin eosio::producer_api_plugin    
# --plugin eosio::producer_plugin    --p2p-peer-address localhost:9000    
# --p2p-peer-address localhost:9001    --p2p-peer-address localhost:9002