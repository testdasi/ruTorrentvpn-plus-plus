#!/bin/bash

# create stubby config if not present and start stubby in background

echo "[info] Create stubby config if not present"
cd /temp && mkdir -p /config/stubby && cp -n ./stubby.yml /config/stubby/ && rm -f ./stubby.yml

echo "[info] Run stubby in background"
stubby -g -C /config/stubby/stubby.yml
