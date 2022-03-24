# solana-info-2-telegram
Shell script that uses Solana and Telegram REST API to send useful stats on a Solana node

## Why?
Solana node validators need to have information about balance on the main identity account, vote account and stake accounts, health of the validator, spent and earned coins during the epoch. 

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

## Update
cd $HOME/solana_bot && git pull

## Usage
Most simple way is to schedule the execution in the cron, below you can see example from my system, it is executed 5 times a day on specific hours:

crontab -l

0 8,12,16,20,22 * * * cd /home/ubuntu/solana_bot; ./check-node.sh

Have a fun with Solana!


