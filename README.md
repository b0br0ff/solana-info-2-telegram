# solana-info-2-telegram
Shell script that uses Solana and Telegram REST API to send useful stats on a Solana node

## Why?
Solana node validators need to have information about balance on the main identity account, vote account and stake accounts, health of the validator, spent and earned coins during the epoch. More KPIs can be easily added, but that is enough in my use case.

Example of the provided information:

![alt text](https://github.com/b0br0ff/solana-info-2-telegram/blob/main/node-info.jpg)


## How?
This script is written in pure Linux shell, I have tested it only in Ubuntu 20.04 LTS. It also uses two modules bc and jq that might be not installed on your system by default. Install them if needed. Of course you need to have a own telegram bot created with bothFather (chat id and token are required). In theory should work under any other Linux distribution. Does not require Solana CLI to be installed on the machine.

Reference to the used documentation:
Solana REST API: https://docs.solana.com/ru/developing/clients/jsonrpc-api#json-rpc-api-reference
Telegram REST API: https://core.telegram.org/bots/api

## Installation
1. Create a Telegram bot using @BotFather or use chat id and token from existing one;
2. Install dependencies if needed: sudo apt install bc jq -y
3. Clone project: git clone https://github.com/b0br0ff/solana-info-2-telegram.git
4. Make scripts executable: chmod+x *.sh
5. Edit script Send_msg_toTelBot.sh and set constants below according to your Telegram bot: 
telegram_bot_token="PUT_HERE_BOT_TOKEN_BY_BOTFATHER"
telegram_chat_id="PUT_HERE_CHAT_ID"
6. Edit script check-node.sh and set account IDs according to your node:
NODE_NAME=PUT_HERE_NODE_NAME"
MAIN_ACC="PUT_HERE_YOUR_NODE_MAIN_ID"
VOTE_ACC="PUT_HERE_YOUR_NODE_VOTE_ACCOUNT"
STAKE1_ACC="PUT_HERE_STAKE1_AACOUN"
STAKE2_ACC="PUT_HERE_STAKE2_AACOUNT"

## Update
Preform same actions as described in "Instalation" chapter.

## Usage
Most simple way is to schedule the execution in the cron, below you can see example from my system, it is executed 5 times a day on specific hours:

crontab -l
0 8,12,16,20,22 * * * cd /home/<YOUR_USER>/solana_bot; ./check-node.sh

Have a fun with Solana validation!

## PS
Script called Send_msg_toTelBot.sh is not written by me, I just modified it a little bit existing one, sorry completely forgot who is the author.

