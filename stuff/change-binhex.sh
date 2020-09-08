#!/bin/bash

# Make changes to binhex scripts

# When connection is down, pick random ovpn
bhf='/root/openvpn.sh'
echo '[info] Fix '"$bhf"
#sed -i 's/openvpn_cli="\/usr\/bin\/openvpn --daemon --reneg-sec/openvpn_cli="\/usr\/bin\/openvpn --daemon --down \/temp\/random-ovpn-fix.sh --reneg-sec/g' "$bhf"
sed -i 's/		pkill /		source \/temp\/random-ovpn-fix.sh \&\& pkill /g' "$bhf"
sed -i 's/		eval /		source \/temp\/random-ovpn-fix.sh \&\& eval /g' "$bhf"

bhf='/root/getvpnport.sh'
echo '[info] Fix '"$bhf"
# When error from getvpn port, pick random ovpn
sed -i 's/		kill -2 /		source \/temp\/random-ovpn-fix.sh \&\& kill -2 /g' "$bhf"
# Reduce number of retries from 12 to 3
sed -i 's/		curly.sh -ct 10 -rc 12 /		curly.sh -ct 10 -rc 3 /g' "$bhf"
