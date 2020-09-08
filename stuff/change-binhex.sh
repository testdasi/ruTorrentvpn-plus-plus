#!/bin/bash

# Make changes to binhex scripts

# When connection is down, pick random ovpn
bhf='/root/openvpn.sh'
echo '[info] Fix '"$bhf"
#sed -i 's/openvpn_cli="\/usr\/bin\/openvpn --daemon --reneg-sec/openvpn_cli="\/usr\/bin\/openvpn --daemon --down \/temp\/random-ovpn.sh --reneg-sec/g' "$bhf"
sed -i 's/		pkill /		\/bin\/bash \/temp\/random-ovpn.sh \&\& pkill /g' "$bhf"
sed -i 's/		eval /		\/bin\/bash \/temp\/random-ovpn.sh \&\& eval /g' "$bhf"

# When openvpn is killed, pick random ovpn
bhf='/root/getvpnport.sh'
echo '[info] Fix '"$bhf"
sed -i 's/		kill -2 /		\/bin\/bash \/temp\/random-ovpn.sh \&\& kill -2 /g' "$bhf"
