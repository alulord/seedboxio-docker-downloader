#!/usr/bin/env bash
nordvpn status | grep "Status: Connected"
exit $?