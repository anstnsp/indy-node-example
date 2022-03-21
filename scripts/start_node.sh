#!/bin/bash 

set -e 

NODE_NAME=$(echo $(grep NODE_NAME /etc/indy/indy.env) | cut -d '=' -f2)
NODE_IP=$(echo $(grep NODE_IP /etc/indy/indy.env) | cut -d '=' -f2)
NODE_PORT=$(echo $(grep NODE_PORT /etc/indy/indy.env) | cut -d '=' -f2)
NODE_CLIENT_IP=$(echo $(grep NODE_CLIENT_IP /etc/indy/indy.env) | cut -d '=' -f2)
NODE_CLIENT_PORT=$(echo $(grep NODE_CLIENT_PORT /etc/indy/indy.env) | cut -d '=' -f2)
start_indy_node $NODE_NAME $NODE_IP $NODE_PORT $NODE_CLIENT_IP $NODE_CLIENT_PORT
