#!/usr/bin/env bash
echo "Services down: $(docker ps -a | grep Exit | awk '{print $NF}')" | pb push