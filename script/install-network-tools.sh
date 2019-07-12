#!/usr/bin/env bash

apt-get update && apt-get -y install iputils-ping \
    traceroute \
    iproute \
    net-tools \
    telnet