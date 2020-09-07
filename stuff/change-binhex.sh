#!/bin/bash

# Make changes to binhex scripts

# When connection is down, pick random ovpn
sed -i 's/openvpn_cli="\/usr\/bin\/openvpn --daemon --reneg-sec/openvpn_cli="\/usr\/bin\/openvpn --daemon --down \/temp\/random-ovpn.sh --reneg-sec/g' /root/openvpn.sh
