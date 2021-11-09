#!/usr/bin/env bash

echo ${HOSTNAME}

export DEBIAN_FRONTEND=noninteractive
sudo apt-get uppdate
sudo apt-get install -y rsyslog