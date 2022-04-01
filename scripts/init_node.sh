#!/bin/bash

set -e

HOST="${HOST:-0.0.0.0}"
NODE_NUM="${1}"
NETWORK_NAME=${2}
NODE_SEED=$(cat ${NODE_SEED})
NODE_NAME=NODE${NODE_NUM}
START_PORT=9700
NODE_PORT=$((START_PORT + ( NODE_NUM * 2 ) - 1 ))

if [ $# -ne 2 ] ; then
  echo "script $0 need 2 parameter(s): nodeNum, networkName"
  exit 1
fi

#/etc/indy/indy_config.py에 있는 네트워크의 이름을 바꿔준다.
awk '{if (index($1, "NETWORK_NAME") != 0) {print("NETWORK_NAME = \"'${NETWORK_NAME}'\"")} else print($0)}' /etc/indy/indy_config.py> /tmp/indy_config.py
mv /tmp/indy_config.py /etc/indy/indy_config.py

#NODE 초기화(init_indy_node)
if [ ! -d "/var/lib/indy/${NETWORK_NAME}" ]; then 
    echo "create dir = /var/lib/indy/${NETWORK_NAME}" 
    mkdir -p /var/lib/indy/${NETWORK_NAME}
    #[node ip] [node port] : node간 통신하기 위한 IP/PORT => node끼리만 sg 허용 해야함. 
    #[client ip] [client port] : node <->client(엔드유저) 간 통신하기 위한 IP/PORT 모든 곳에서 오는 통신 허용 해야함.
    #init_indy_node [noee별칭] [node ip] [node port] [client ip] [client port] [node seed]
    init_indy_node ${NODE_NAME} ${HOST} ${NODE_PORT} ${HOST} $(( NODE_PORT + 1 )) ${NODE_SEED} > /var/lib/indy/${NETWORK_NAME}/init_output
else 
    echo "already created dir = /var/lib/indy/${NETWORK_NAME}" 
fi

#TRUSTEE 
if [ $NODE_NUM == "1" ]; then 

  $HOME/scripts/generate_id.py $(cat $HOME/scripts/seeds/trustees/trustees$NODE_NUM-seed) >> /tmp/trustee$NODE_NUM-did-verkey

  TRUSTEE_DID=$(grep "DID" /tmp/trustee$NODE_NUM-did-verkey | awk '{print $3}')
  TRUSTEE_VERKEY=$(grep "verkey" /tmp/trustee$NODE_NUM-did-verkey | awk '{print $3}')
  echo -e "TRUSTEE_NAME$NODE_NUM,${TRUSTEE_DID},${TRUSTEE_VERKEY}" >> /tmp/trustee$NODE_NUM.csv #TREUSTEE.CSV

fi

#STEWARD
NODE_VERKEY=$(grep Verification /var/lib/indy/$NETWORK_NAME/init_output | head -n 1 |  awk '{print $4}')
NODE_IP="192.168.59.100" #minikube ip 
BLSKEY=$(grep "BLS Public key" /var/lib/indy/$NETWORK_NAME/init_output | awk '{print $5}')
BLSKEY_POP=$(grep "Proof of possession" /var/lib/indy/$NETWORK_NAME/init_output | awk '{print $8}')

$HOME/scripts/generate_id.py $(cat $HOME/scripts/seeds/stewards/stewards$NODE_NUM-seed) >> /tmp/steward$NODE_NUM-did-verkey

STEWARD_DID=$(grep "DID" /tmp/steward$NODE_NUM-did-verkey | awk '{print $3}')
STEWARD_VERKEY=$(grep "verkey" /tmp/steward$NODE_NUM-did-verkey | awk '{print $3}')

echo -e "${STEWARD_DID},${STEWARD_VERKEY},${NODE_NAME},${NODE_IP},${NODE_PORT},${NODE_IP},$(( NODE_PORT + 1 )),${NODE_VERKEY},${BLSKEY},${BLSKEY_POP}" >> /tmp/steward$NODE_NUM.csv #STEWARD>CSV 
