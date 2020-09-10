#!/bin/bash

#new start scripts
rm -f /root/start.sh
cp /temp/new_start.sh /root/start.sh
chmod +x /root/start.sh

#random VPN picker
source /temp/random-ovpn.sh

#stubby initialisation
source /temp/stubby.sh

# binhex init script
source /usr/local/bin/init.sh
