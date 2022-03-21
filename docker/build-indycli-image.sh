#!/bin/bash

VERSION=1.0

docker image build -t indy-cli:${VERSION} -f indy-cli.dockerfile .
