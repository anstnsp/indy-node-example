#!/bin/bash 

#1.TRUSTEE 시드 생성 
#2.STEWARD 시드 생성 
#
#

set -e

NODE_CNT=4
TRUSTEE_CNT=1
NETWORK_NAME=test-network 

# =================================================================================================================
# Usage:
# -----------------------------------------------------------------------------------------------------------------
usage () {
  cat <<-EOF

  Usage: $0 [command] [--logs] [options]

  Commands:

  read shell file 
EOF
exit 1
}

function genSeed() {
    echo $(pwgen -s 32 -1)
}

function createRoleSeed() {
role=$1

echo "###### START >> Create ${role} Seed ######"
if [ ! -d "./seeds/${role}" ]; then
    mkdir -p scripts/seeds/${role}
else
    echo "already exists seeds/${role} dir!!"
    exit 1
fi 
#Trustee 시드생성 
if [ "${role}" == "trustees" ]; then 
    for ((var=1 ; var <= $TRUSTEE_CNT ; var++)); 
    do
        echo $(genSeed) > scripts/seeds/${role}/${role}$var-seed
    done 
fi 
#Steward 시드생성 
if [ "${role}" == "stewards" ]; then 
    for ((var=1 ; var <= $NODE_CNT ; var++)); 
    do
        echo $(genSeed) > scripts/seeds/${role}/${role}$var-seed  
    done 
fi 
#Validator Node 시드생성 
if [ "${role}" == "nodes" ]; then 
    for ((var=1 ; var <= $NODE_CNT ; var++)); 
    do
        echo $(genSeed) > scripts/seeds/${role}/${role}$var-seed    
    done 
fi 

# for ((var=1 ; var <= $NODE_CNT ; var++)); 
# do
#     if [ "${role}" == "trustees" ]; then
#     TRUSTEE${NODE_CNT}_SEED=$(genSeed) 
#     echo $(genSeed) > scripts/seeds/${role}/${role}-seed$var         
#     # echo $(genSeed) > scripts/seeds/${role}/${role}-seed$var         
#     elif [ "${role}" == "stewards" ]; then
#         STEWARD${NODE_CNT}_SEED=$(genSeed) 
#         echo $(genSeed) > scripts/seeds/${role}/${role}-seed$var         
#     elif [ "${role}" == "nodes" ]; then
#         NODE${NODE_CNT}_SEED=$(genSeed) 
#         echo $(genSeed) > scripts/seeds/${role}/${role}-seed$var         
#     else
#         echo "no role"
#         exit 1
#     fi 
# done
echo "###### END >> Create ${role} Seed ######"
    
}

function genDidandVerkey() {
    mkdir -p ./didverkey
    ./scripts/generate_id.py $1
}

# $HOME/scripts/generate_id.py $(cat /var/lib/indy/truteeseed) > /tmp/did-verkey

# TRUSTEE_DID=$(grep "DID" /tmp/did-verkey | awk '{print $3}')
# VERKEY=$(grep "verkey" /tmp/did-verkey | awk '{print $3}')

function init_node() {
    #Seed 생성 
    createRoleSeed trustees
    createRoleSeed stewards
    createRoleSeed nodes

    #Node 초기화 => init_indy_node, csv 파일생성 등...
    docker-compose up -d node1 node2 node3 node4 

    sleep 15

    #제네시스파일을 위한 trustees.csv, stewards.csv 파일 만들기 
    mkdir -p $PWD/tmp
    docker cp node1:/tmp/trustee1.csv $HOME/myProjects/indy/my-indy-node-local/tmp/
    docker cp node1:/tmp/steward1.csv $HOME/myProjects/indy/my-indy-node-local/tmp/
    docker cp node2:/tmp/steward2.csv $HOME/myProjects/indy/my-indy-node-local/tmp/
    docker cp node3:/tmp/steward3.csv $HOME/myProjects/indy/my-indy-node-local/tmp/
    docker cp node4:/tmp/steward4.csv $HOME/myProjects/indy/my-indy-node-local/tmp/

    cp $PWD/scripts/createPool/stewards.csv $PWD/tmp/stewards.csv  
    cp $PWD/scripts/createPool/trustees.csv $PWD/tmp/trustees.csv  

    cat $HOME/myProjects/indy/my-indy-node-local/tmp/trustee1.csv >>  $PWD/tmp/trustees.csv
    cat $HOME/myProjects/indy/my-indy-node-local/tmp/steward1.csv >> $PWD/tmp/stewards.csv
    cat $HOME/myProjects/indy/my-indy-node-local/tmp/steward2.csv >> $PWD/tmp/stewards.csv
    cat $HOME/myProjects/indy/my-indy-node-local/tmp/steward3.csv >> $PWD/tmp/stewards.csv
    cat $HOME/myProjects/indy/my-indy-node-local/tmp/steward4.csv >> $PWD/tmp/stewards.csv

    docker cp $PWD/tmp/trustees.csv node1:/tmp 
    docker cp $PWD/tmp/stewards.csv node1:/tmp

    #제네시스파일 생성 
    docker exec node1 cp /home/indy/scripts/genesis_from_files.py /tmp  
    docker cp $PWD/scripts/genesis_from_files.py node1:/tmp/
    docker exec node1 bash -c "cd /tmp; /tmp/genesis_from_files.py --trustees /tmp/trustees.csv --stewards /tmp/stewards.csv"
    
    #제네시스파일을 /var/lib/indy/$NETWORK_NAME 위치로 복사
    docker exec node1 cp /tmp/domain_transactions_genesis /var/lib/indy/$NETWORK_NAME/
    docker exec node1 cp /tmp/pool_transactions_genesis /var/lib/indy/$NETWORK_NAME/

    #제네시스 파일을 각 노드로 복사 (node1 -> host)
    docker cp node1:/tmp/domain_transactions_genesis $PWD/tmp
    docker cp node1:/tmp/pool_transactions_genesis $PWD/tmp
    
    #제네시스 파일을 각 노드로 복사 (host -> node2)
    docker cp $PWD/tmp/domain_transactions_genesis node2:/var/lib/indy/$NETWORK_NAME/
    docker cp $PWD/tmp/pool_transactions_genesis node2:/var/lib/indy/$NETWORK_NAME/
    #제네시스 파일을 각 노드로 복사 (host -> node3)
    docker cp $PWD/tmp/domain_transactions_genesis node3:/var/lib/indy/$NETWORK_NAME/
    docker cp $PWD/tmp/pool_transactions_genesis node3:/var/lib/indy/$NETWORK_NAME/
    #제네시스 파일을 각 노드로 복사 (host -> node4)
    docker cp $PWD/tmp/domain_transactions_genesis node4:/var/lib/indy/$NETWORK_NAME/
    docker cp $PWD/tmp/pool_transactions_genesis node4:/var/lib/indy/$NETWORK_NAME/

}

function start_node() {
    docker exec node1 /home/indy/scripts/start_node.sh
    docker exec node2 /home/indy/scripts/start_node.sh
    docker exec node3 /home/indy/scripts/start_node.sh
    docker exec node4 /home/indy/scripts/start_node.sh
}

function down_node() {
    docker-compose down 
    docker volume prune 
    rm -rf ./scripts/seeds
    rm -rf ./tmp 
}
# NODE_NUM="${1}"
# NETWORK_NAME=${2}
# NODE_SEED=${3}


# docker-comppose up -d indy-cli 

# ./init_node.sh 

if [ "$1" == "seed-trustees" ]; then
  createRoleSeed trustees
elif [ "$1" == "seed-stewards" ]; then
    createRoleSeed stewards
elif [ "$1" == "seed-nodes" ]; then ## Clear the network
    createRoleSeed nodes
elif [ "$1" == "seed-all" ]; then 
    createRoleSeed trustees
    createRoleSeed stewards
    createRoleSeed nodes
elif [ "$1" == "seed-remove" ]; then 
    rm -rf ./seeds
elif [ "$1" == "init-node" ]; then 
    init_node 
elif [ "$1" == "start-node" ]; then 
    start_node 
elif [ "$1" == "gendidverkey" ]; then 
    genDidandVerkey
elif [ "$1" == "down-node" ]; then 
    down_node
else
  usage
  exit 1
fi


