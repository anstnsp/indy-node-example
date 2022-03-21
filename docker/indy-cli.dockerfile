FROM ubuntu:16.04

RUN apt-get update && apt-get install -y  \
    apt-transport-https \
    pwgen \
	python3.5 \
	python3-pip \
	python-setuptools \
	python3-nacl 

COPY cli-scripts /cli-scripts

ARG indy_stream=stable

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CE7709D068DB5E88
RUN echo "deb https://repo.sovrin.org/sdk/deb xenial $indy_stream" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y indy-cli
