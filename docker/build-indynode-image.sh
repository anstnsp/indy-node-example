#!/bin/bash


VERSION=1.0

docker build -t indy-node:${VERSION} -f indy-node.dockerfile .
