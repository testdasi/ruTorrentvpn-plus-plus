#!/bin/bash

# Randomly pick an ovpn file from set and replace OpenVPN config with this new file

echo "[info] Pick a random ovpn file"
src='/config/openvpn_files'
des='/config/openvpn'
mkdir -p $src
ls $src/*.ovpn | sort -R | tail -1 | while read file; do
    cp --force "$file" "$des/openvpn.ovpn"
    echo "[info] ${file} picked"
done

