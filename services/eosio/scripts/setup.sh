#!/bin/bash

source $(dirname $0)/init_chain.sh

echo
echo "stepKillAll..."
stepKillAll
echo

# read -p "Press [Enter] to setup stepStartWallet..."
echo
stepStartWallet
echo

# read -p "Press [Enter] to setup stepInitNodes..."
echo
stepInitNodes
echo

# read -p "Press [Enter] to setup stepStartBoot..."
echo
stepStartBoot
echo

# read -p "Press [Enter] to setup createSystemAccounts..."
echo
createSystemAccounts
echo

# read -p "Press [Enter] to setup stepInstallSystemContracts..."
echo
stepInstallSystemContracts
echo

# read -p "Press [Enter] to setup stepCreateTokens..."
echo
stepCreateTokens
echo

# read -p "Press [Enter] to setup stepSetSystemContract..."
echo
stepSetSystemContract
echo

# read -p "Press [Enter] to setup stepInitSystemContract..."
echo
stepInitSystemContract

# stepCreateStakedAccounts
# stepRegProducers
echo

# read -p "Press [Enter] to setup stepStartProducers..."
echo
stepStartProducers

# stepVote
# claimRewards
# stepProxyVotes
# stepResign
# msigReplaceSystem
# stepTransfer
# stepLog



# echo

# read -p "Press [Enter] to setup producers..."
# echo
# set_producers

# read -p "Press [Enter] set voter..."
# set_voters

# echo
# read -p "Press [Enter] to vote..."
# run_vote



echo " --------"
echo "|Done... |"
echo " --------"