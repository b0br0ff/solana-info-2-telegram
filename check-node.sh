#!/usr/bin/bash
# Author: b0br0ff
# Prereqs: bc, jq

DEBUG=1

### Initialize variables below with your data
NODE_NAME=PUT_HERE_NODE_NAME"
MAIN_ACC="PUT_HERE_YOUR_NODE_MAIN_ID"
VOTE_ACC="PUT_HERE_YOUR_NODE_VOTE_ACCOUNT"
STAKE1_ACC="PUT_HERE_STAKE1_AACOUN"
STAKE2_ACC="PUT_HERE_STAKE2_AACOUNT"

API_URL="https://api.mainnet-beta.solana.com"
#API_URL="https://api.testnet.solana.com" 

# Constants for spent/earned calculations
CREDIT_PRICE=0.000005
BLOCK_PRICE=0.00375
# Icons for telegram bot
OK_ICON=`echo -e '\U0002705'`
NOK_ICON=`echo -e '\U000274C'

function get_spent_sol(){
    local JSON="$1"
    local EPOCH_ID=$2
    local BLOCKS=$3

    local CREDITS_CURRENT=$(echo $JSON | jq '.result.current[].epochCredits['$EPOCH_ID'][1]')
    local CREDITS_PREV=$(echo $JSON | jq '.result.current[].epochCredits['$EPOCH_ID'][2]')
    local CREDITS_DIF=$(( $CREDITS_CURRENT - $CREDITS_PREV ))
    local SPENT_SOL=$(echo "scale=2; ${CREDITS_DIF}*${CREDIT_PRICE}-${BLOCKS}*${BLOCK_PRICE}" | bc)
    echo $SPENT_SOL
}

function get_stake_status(){
        local STAKE_ACC="$1"

        local STAKE_JSON=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0", "id":1, "method":"getStakeActivation", "params":["'${STAKE_ACC}'"]}')
        local STAKE_SOL=$(echo ${STAKE_JSON} | jq '.result.active')
        STAKE_SOL=$(echo "scale=2; ${STAKE_SOL}/1000000000" | bc)
        local STAKE_STATE=$(echo ${STAKE_JSON} | jq '.result.state')
        echo "${STAKE_SOL} SOL, ${STAKE_STATE}"
}

# Get main ID balance
MAIN_BALANCE=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0", "id":1, "method":"getBalance", "params":["'${MAIN_ACC}'"]}' | jq '.result.value')
MAIN_BALANCE=$(echo "scale=2; ${MAIN_BALANCE}/1000000000" | bc)

# Get vote balance
VOTE_BALANCE=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0", "id":1, "method":"getBalance", "params":["'${VOTE_ACC}'"]}' | jq '.result.value')
VOTE_BALANCE=$(echo "scale=2; ${VOTE_BALANCE}/1000000000" | bc)

# Get scheduled slots
SLOTS_CNT=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{ "jsonrpc":"2.0","id":1, "method":"getLeaderSchedule", "params": [ null, { "identity": "'${MAIN_ACC}'" }] }' | jq '.result."'${MAIN_ACC}'"' | wc -l)
SLOTS_CNT=$(echo "${SLOTS_CNT} -2" | bc)

# Get self stake status
STAKE1_STATUS=$(get_stake_status "${STAKE1_ACC}")
STAKE2_STATUS=$(get_stake_status "${STAKE2_ACC}")

# Get epoch
EPOCH_NUM=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":1, "method":"getEpochInfo"}' | jq '.result.epoch')
PREV_EPOCH=$(( $EPOCH_NUM - 1 ))

# Get total stake
STAKE_TOTAL_JSON=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":1, "method":"getVoteAccounts", "params": [{ "votePubkey": "'${VOTE_ACC}'" } ]}')
STAKE_ACT=$(echo ${STAKE_TOTAL_JSON}  | jq '.result.current[].activatedStake')
STAKE_ACT=$(echo "scale=2; ${STAKE_ACT}/1000000000" | bc)

#Get commission
COMM_PECENT=$(echo ${STAKE_TOTAL_JSON}  | jq '.result.current[].commission')

#Get delinquent
DELINQUENT_NODE=$(echo ${STAKE_TOTAL_JSON}  | jq '.result.delinquent[].nodePubkey')

#Get lamports for previous and current epochs
PREV_LAMPORTS=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":1, "method":"getInflationReward", "params": [ ["'${VOTE_ACC}'"], {"epoch": '$PREV_EPOCH'} ]}' | jq '.result[].amount')
EARNED_LAMPORTS=$(echo "scale=2; ${PREV_LAMPORTS}/1000000000" | bc)

#Get blocks production
BLOCKS_PRODUCTION_JSON=$(curl --silent -X POST ${API_URL} -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","id":1, "method":"getBlockProduction", "params": [{ "identity": "'${MAIN_ACC}'" } ]}')
BLOCKS_PRODUCED=$(echo ${BLOCKS_PRODUCTION_JSON} | jq '.result.value.byIdentity."'${MAIN_ACC}'"[1]')
SPENT_SOL=$(get_spent_sol ${STAKE_TOTAL_JSON} -1 ${BLOCKS_PRODUCED})

# Debug info
if [ "$DEBUG" -eq 1 ]; then
	echo "Epoch = ${EPOCH_NUM}"
	echo "Total blocks = ${SLOTS_CNT}"
	echo "Produced blocks = ${BLOCKS_PRODUCED}"
	echo "Comission = ${COMM_PECENT}%"
	echo "Main ID balance = ${MAIN_BALANCE} SOL"
	echo "Vote balance = ${VOTE_BALANCE} SOL"
	echo "Self-stake 1 = ${STAKE1_STATUS}"
	echo "Self-stake 2 = ${STAKE2_STATUS}"
	echo "Active stake = ${STAKE_ACT} SOL"
	echo "Delinquent status = ${DELINQUENT_NODE}"
	echo "Earned = ${EARNED_LAMPORTS} SOL in epoch ${PREV_EPOCH}"
	echo "Spent ${SPENT_SOL} SOL in epoch ${EPOCH_NUM}"
fi

# in case of 1 self stake
#MSG=$(echo "Epoch = ${EPOCH_NUM}%0ATotal blocks = ${SLOTS_CNT}%0AProduced blocks = ${BLOCKS_PRODUCED}%0AComission = ${COMM_PECENT}%%0AMain ID balance = ${MAIN_BALANCE} SOL%0AVote balance = ${VOTE_BALANCE} SOL%0ASelf-stake 1 = ${STAKE1_STATUS}%0AActive stake = ${STAKE_ACT} SOL%0AEarned in prev epoch = ${EARNED_LAMPORTS} SOL%0ASpent = ${SPENT_SOL} SOL in epoch")
# in case of 2 self stakes
MSG=$(echo "Epoch = ${EPOCH_NUM}%0ATotal blocks = ${SLOTS_CNT}%0AProduced blocks = ${BLOCKS_PRODUCED}%0AComission = ${COMM_PECENT}%%0AMain ID balance = ${MAIN_BALANCE} SOL%0AVote balance = ${VOTE_BALANCE} SOL%0ASelf-stake 1 = ${STAKE1_STATUS}%0ASelf-stake 2 = ${STAKE2_STATUS}%0AActive stake = ${STAKE_ACT} SOL%0AEarned in prev epoch = ${EARNED_LAMPORTS} SOL%0ASpent = ${SPENT_SOL} SOL in epoch")

if [ "${DELINQUENT_NODE}" = "" ]; then
   ./Send_msg_toTelBot.sh "${OK_ICON} ${NODE_NAME} Info ${OK_ICON}" "${MSG}"
else
   ./Send_msg_toTelBot.sh "${NOK_ICON} ${NODE_NAME} Info ${NOK_ICON}" "${MSG}%0ADelinquent status = ${DELINQUENT_NODE}"
fi
