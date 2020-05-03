#!/usr/bin/env bash
if [[ "$(docker ps -a | grep Exit)" == "" ]]; then
    exit 0
fi
exit 1