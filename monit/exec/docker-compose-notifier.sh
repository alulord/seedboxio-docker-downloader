#!/usr/bin/env bash
source /etc/environment
echo "Services down: $(docker ps -a | grep Exit | awk '{print $NF}')" | pb push