FROM ubuntu:16.04

ARG uid=1000

RUN apt-get update -y && apt-get install -y \
    git \
    apt-transport-https \
	ca-certificates \
    pwgen \
    netcat 
     

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys CE7709D068DB5E88 || \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys CE7709D068DB5E88

RUN bash -c 'echo "deb https://repo.sovrin.org/deb xenial stable" >> /etc/apt/sources.list' 
RUN apt-get update
RUN apt-get install -y indy-node

USER indy

WORKDIR /home/indy
# RUN awk '{if (index($1, "NETWORK_NAME") != 0) {print("NETWORK_NAME = \"anstn-network\"")} else print($0)}' /etc/indy/indy_config.py> /tmp/indy_config.py
# RUN mv /tmp/indy_config.py /etc/indy/indy_config.py

EXPOSE 9701 9702 9703 9704 9705 9706 9707 9708
