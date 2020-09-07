#!/bin/bash

echo "[info] Pick a random ovpn file"
# randomly pick an ovpn file from set i.e. refresh IP
src='/config/openvpn_files'
des='/config/openvpn'
mkdir -p $src
ls $src/*.ovpn | sort -R | tail -1 | while read file; do
    cp --force "$file" "$des/openvpn.ovpn"
done
echo "[info] $file picked"
