# ruTorrentvpn-plus-plus
ruTorrent with OpenVPN client, http proxy, dns-over-tls and a random ovpn picker.

## High-level instructions
* Run docker - first run will stop itself due to missing ovpn file
* Copy / extract your ovpn files in the host path that is mapped to */config/ovpn_files* (at least 1 file is required, must have .ovpn extension)
* If there are separate cert files (crt + pem), place them in host location path that is mapped to */config/ovpn*. This is not required if you use PIA ovpn files as they include the certs in the ovpn.
* Start docker again

## Credit
Based on [binhex/arch-rtorrentvpn](https://hub.docker.com/r/binhex/arch-rtorrentvpn).

## Key features
1. ruTorrent + rTorrent
1. OpenVPN client to connect to your favourite VPN provider. Note: require port forwarding!
1. Random ovpn picker at start/restart, useful if a server stops working. Note: multiple ovpn files required e.g. [PIA ovpn files](https://www.privateinternetaccess.com/openvpn/openvpn.zip))
1. Privoxy for http proxy (ip:8118)
1. Stubby for dns-over-tls client (ip:53 or 127.2.2.2:53 or 127.2.2.2:5253)
1. Minor / cosmetic fixes

## Usage
    docker run -d \
        --cap-add=NET_ADMIN \
        -p 9080:9080 \
        -p 9443:9443 \
        -p 8118:8118 \
        --name=<container name> \
        -v <path for data files>:/data \
        -v <path for config files>:/config \
        -v /etc/localtime:/etc/localtime:ro \
        -e VPN_ENABLED=<yes|no> \
        -e VPN_USER=<vpn username> \
        -e VPN_PASS=<vpn password> \
        -e VPN_PROV=<pia|airvpn|custom> \
        -e VPN_OPTIONS=<additional openvpn cli options> \
        -e STRICT_PORT_FORWARD=<yes|no> \
        -e ENABLE_PRIVOXY=<yes|no> \
        -e ENABLE_AUTODL_IRSSI=<yes|no> \
        -e ENABLE_RPC2=<yes|no> \
        -e ENABLE_RPC2_AUTH=<yes|no> \
        -e ENABLE_WEBUI_AUTH=<yes|no> \
        -e RPC2_USER=<rpc2 username> \
        -e RPC2_PASS=<rpc2 password> \
        -e WEBUI_USER=<webui username> \
        -e WEBUI_PASS=<webui password> \
        -e LAN_NETWORK=<lan ipv4 network>/<cidr notation> \
        -e NAME_SERVERS=<name server ip(s)> \
        -e ADDITIONAL_PORTS=<port number(s)> \
        -e DEBUG=<true|false> \
        -e PHP_TZ=<php timezone> \
        -e UMASK=<umask for created files> \
        -e PUID=<uid for user> \
        -e PGID=<gid for user> \
        testdasi/ruTorrentvpn-plus-plus

## Unraid + PIA example
    docker run -d \
        --name='rutorrentvpn-plus-plus' \
        --cap-add=NET_ADMIN \
        -e TZ="Europe/London" \
        -e HOST_OS="Unraid" \
        -e 'VPN_ENABLED'='yes' \
        -e 'VPN_USER'='VPN_USER' \
        -e 'VPN_PASS'='VPN_PASS' \
        -e 'VPN_PROV'='pia' \
        -e 'VPN_OPTIONS'='' \
        -e 'STRICT_PORT_FORWARD'='yes' \
        -e 'LAN_NETWORK'='192.168.0.1/24' \
        -e 'NAME_SERVERS'='127.2.2.2' \
        -e 'ADDITIONAL_PORTS'='' \
        -e 'ENABLE_PRIVOXY'='yes' \
        -e 'ENABLE_AUTODL_IRSSI'='no' \
        -e 'ENABLE_RPC2'='yes' \
        -e 'ENABLE_RPC2_AUTH'='yes' \
        -e 'RPC2_USER'='RPC2_USER' \
        -e 'RPC2_PASS'='RPC2_PASS' \
        -e 'ENABLE_WEBUI_AUTH'='yes' \
        -e 'WEBUI_USER'='WEBUI_USER' \
        -e 'WEBUI_PASS'='WEBUI_PASS' \
        -e 'DEBUG'='no' \
        -e 'PHP_TZ'='UTC' \
        -e 'UMASK'='000' \
        -e 'PUID'='99' \
        -e 'PGID'='100' \
        -p '5000:5000/tcp' \
        -p '9080:9080/tcp' \
        -p '9443:9443/tcp' \
        -p '8118:8118/tcp' \
        -v '/mnt/user/appdata/rutorrentvpn-plus-plus':'/config':'rw' \
        -v '/mnt/user/downloads/rutorrentvpn-plus-plus/':'/data':'rw' \
        'testdasi/rutorrentvpn-plus-plus'

## Notes
* I code for fun and my personal uses; hence, these niche functionalties that nobody asks for. ;)
* Tested exclusively with [PIA ovpn files](https://www.privateinternetaccess.com/openvpn/openvpn.zip)
* Intended to be used with Unraid but would work in other x86/amd64 environments too.
  
