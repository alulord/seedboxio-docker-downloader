#!/usr/bin/env bash
/usr/bin/nordvpn status | grep "Status: Connected"
exit $?