#!/bin/bash

# location of your proxy-establishing-functions script
thescript="./functions.d/S30proxystate.rc"

# just a reminder
echo "[*] Don't forget to either export MYPROXY=somevalue or edit $thescript directly to establish"
echo "    your proxy value(s) before running this script."

# source the proxy functions and call them
source $thescript
echo "[*] Turning on the CLI proxies."
proxyon
echo "[*] The current state of CLI proxy variables:"
proxystate
