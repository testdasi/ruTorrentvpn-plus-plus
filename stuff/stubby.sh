#!/bin/bash

# create stubby config if not present and start stubby in background
cd /temp && mkdir -p /config/stubby && cp -n ./stubby.yml /config/stubby/ && rm -f ./stubby.yml
stubby -g -C /config/stubby/stubby.yml
