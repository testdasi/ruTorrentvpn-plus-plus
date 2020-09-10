#!/bin/bash

#new start scripts
rm -f /root/start.sh
cp /temp/new_start.sh /root/start.sh
chmod +x /root/start.sh

#random VPN picker
/bin/bash /temp/random-ovpn.sh

#stubby initialisation
/bin/bash /temp/stubby.sh

# binhex init script
/bin/bash /usr/local/bin/init.sh
