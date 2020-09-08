#!/bin/bash

# if vpn set to "no" then don't run openvpn
if [[ "${VPN_ENABLED}" == "no" ]]; then

	echo "[info] VPN not enabled, skipping configuration of VPN"

else

	echo "[info] VPN is enabled, beginning configuration of VPN"

	if [[ "${DEBUG}" == "true" ]]; then
		echo "[debug] Environment variables defined as follows" ; set
		echo "[debug] Directory listing of files in /config/openvpn as follows" ; ls -al /config/openvpn
	fi

	# if vpn username and password specified then write credentials to file (authentication maybe via keypair)
	if [[ ! -z "${VPN_USER}" && ! -z "${VPN_PASS}" ]]; then

		# store credentials in separate file for authentication
		if ! $(grep -Fq "auth-user-pass credentials.conf" /config/openvpn/openvpn.ovpn); then
			sed -i -e 's/auth-user-pass.*/auth-user-pass credentials.conf/g' /config/openvpn/openvpn.ovpn
		fi

		echo "${VPN_USER}" > /config/openvpn/credentials.conf

		username_char_check=$(echo "${VPN_USER}" | grep -P -o -m 1 '[^a-zA-Z0-9@]+')

		if [[ ! -z "${username_char_check}" ]]; then
			echo "[warn] Username contains characters which could cause authentication issues, please consider changing this if possible"
		fi

		echo "${VPN_PASS}" >> /config/openvpn/credentials.conf

		password_char_check=$(echo "${VPN_PASS}" | grep -P -o -m 1 '[^a-zA-Z0-9@]+')

		if [[ ! -z "${password_char_check}" ]]; then
			echo "[warn] Password contains characters which could cause authentication issues, please consider changing this if possible"
		fi

	fi

	# note - do not remove redirection of gateway for ipv6 - required for certain vpn providers (airvpn)

	# remove persist-tun from ovpn file if present, this allows reconnection to tunnel on disconnect
	sed -i '/^persist-tun/d' /config/openvpn/openvpn.ovpn

	# remove reneg-sec from ovpn file if present, this is removed to prevent re-checks and dropouts
	sed -i '/^reneg-sec.*/d' /config/openvpn/openvpn.ovpn

	# remove up script from ovpn file if present, this is removed as we do not want any other up/down scripts to run
	sed -i '/^up\s.*/d' /config/openvpn/openvpn.ovpn

	# remove down script from ovpn file if present, this is removed as we do not want any other up/down scripts to run
	sed -i '/^down\s.*/d' /config/openvpn/openvpn.ovpn

	# remove ipv6 configuration from ovpn file if present (iptables not configured to support ipv6)
	sed -i '/^route-ipv6/d' /config/openvpn/openvpn.ovpn

	# remove ipv6 configuration from ovpn file if present (iptables not configured to support ipv6)
	sed -i '/^ifconfig-ipv6/d' /config/openvpn/openvpn.ovpn

	# remove ipv6 configuration from ovpn file if present (iptables not configured to support ipv6)
	sed -i '/^tun-ipv6/d' /config/openvpn/openvpn.ovpn

	# remove dhcp option for dns ipv6 configuration from ovpn file if present (dns defined via name_server env var value)
	sed -i '/^dhcp-option DNS6.*/d' /config/openvpn/openvpn.ovpn

	# remove windows specific openvpn options
	sed -i '/^route-method exe/d' /config/openvpn/openvpn.ovpn
	sed -i '/^service\s.*/d' /config/openvpn/openvpn.ovpn
	sed -i '/^block-outside-dns/d' /config/openvpn/openvpn.ovpn

	if [[ "${DEBUG}" == "true" ]]; then
		echo "[debug] Contents of ovpn file ${VPN_CONFIG} as follows..." ; cat /config/openvpn/openvpn.ovpn
	fi

	# assign any matching ping options in ovpn file to variable (used to decide whether to specify --keealive option in openvpn.sh)
	vpn_ping=$(cat /config/openvpn/openvpn.ovpn | grep -P -o -m 1 '^ping.*')

	# forcibly set virtual network device to 'tun0/tap0' (referenced in iptables)
	sed -i "s/^dev\s${VPN_DEVICE_TYPE}.*/dev ${VPN_DEVICE_TYPE}/g" /config/openvpn/openvpn.ovpn

	# get ip for local gateway (eth0)
	DEFAULT_GATEWAY=$(ip route show default | awk '/default/ {print $3}')
	echo "[info] Default route for container is ${DEFAULT_GATEWAY}"

	# split comma seperated string into list from NAME_SERVERS env variable
	IFS=',' read -ra name_server_list <<< "${NAME_SERVERS}"

	# remove existing ns, docker injects ns from host and isp ns can block/hijack
	> /etc/resolv.conf

	# process name servers in the list
	for name_server_item in "${name_server_list[@]}"; do

		# strip whitespace from start and end of name_server_item
		name_server_item=$(echo "${name_server_item}" | sed -e 's~^[ \t]*~~;s~[ \t]*$~~')

		echo "[info] Adding ${name_server_item} to /etc/resolv.conf"
		echo "nameserver ${name_server_item}" >> /etc/resolv.conf

	done

	# if the vpn_remote is NOT an ip address then resolve it
	if ! echo "${VPN_REMOTE}" | grep -P -o '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}'; then

		retry_count=12
		remote_dns_answer=$(drill -a -4 "${VPN_REMOTE}" | grep -v 'SERVER' | grep -m 63 -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | xargs)

		while [ -z "${remote_dns_answer}" ]; do

			retry_count=$((retry_count-1))
			if [ "${retry_count}" -eq "0" ]; then

				echo "[crit] '${VPN_REMOTE}' cannot be resolved, possible DNS issues, exiting..." ; exit 1

			else

				remote_dns_answer=$(drill -a -4 "${VPN_REMOTE}" | grep -v 'SERVER' | grep -m 63 -oE '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | xargs)

				if [[ "${DEBUG}" == "true" ]]; then

						echo "[debug] Failed to resolve endpoint '${VPN_REMOTE}' retrying..."

				fi

				sleep 5s

			fi

		done

		# get first ip from remote_dns_answer and write to the hosts file
		# this is required as openvpn will use the remote entry in the ovpn file
		# even if you specify the --remote options on the command line, and thus we
		# must also be able to resolve the host name (assuming it is a name and not ip).
		remote_dns_answer_first=$(echo "${remote_dns_answer}" | cut -d ' ' -f 1)

		# if not blank then write to hosts file
		if [[ ! -z "${remote_dns_answer_first}" ]]; then
			echo "${remote_dns_answer_first}	${VPN_REMOTE}" >> /etc/hosts
		fi

	else
		remote_dns_answer_first="${VPN_REMOTE}"
	fi
	
	# check if we have tun module available
	check_tun_available=$(lsmod | grep tun)

	# if tun module not available then try installing it
	if [[ -z "${check_tun_available}" ]]; then
		echo "[info] Attempting to load tun kernel module..."
		/sbin/modprobe tun
		tun_module_exit_code=$?
		if [[ $tun_module_exit_code != 0 ]]; then
			echo "[warn] Unable to load tun kernel module using modprobe, trying insmod..."
			insmod /lib/modules/tun.ko
			tun_module_exit_code=$?
			if [[ $tun_module_exit_code != 0 ]]; then
				echo "[warn] Unable to load tun kernel module, assuming its dynamically loaded"
			fi
		fi
	fi

	# create the tunnel device if not present (unraid users do not require this step)
	mkdir -p /dev/net
	[ -c "/dev/net/tun" ] || mknod "/dev/net/tun" c 10 200
	tun_create_exit_code=$?
	if [[ $tun_create_exit_code != 0 ]]; then
		echo "[crit] Unable to create tun device, try adding docker container option '--device=/dev/net/tun'" ; exit 1
	else
		chmod 600 /dev/net/tun
	fi

	# check if we have iptable_mangle module available
	check_mangle_available=$(lsmod | grep iptable_mangle)

	# if mangle module not available then try installing it
	if [[ -z "${check_mangle_available}" ]]; then
		echo "[info] Attempting to load iptable_mangle module..."
		/sbin/modprobe iptable_mangle
		mangle_module_exit_code=$?
		if [[ $mangle_module_exit_code != 0 ]]; then
			echo "[warn] Unable to load iptable_mangle module using modprobe, trying insmod..."
			insmod /lib/modules/iptable_mangle.ko
			mangle_module_exit_code=$?
			if [[ $mangle_module_exit_code != 0 ]]; then
				echo "[warn] Unable to load iptable_mangle module, you will not be able to connect to the applications Web UI or Privoxy outside of your LAN"
				echo "[info] unRAID/Ubuntu users: Please attempt to load the module by executing the following on your host: '/sbin/modprobe iptable_mangle'"
				echo "[info] Synology users: Please attempt to load the module by executing the following on your host: 'insmod /lib/modules/iptable_mangle.ko'"
			fi
		fi
	fi

	if [[ "${DEBUG}" == "true" ]]; then
		echo "[debug] Show name servers defined for container" ; cat /etc/resolv.conf
		echo "[debug] Show name resolution for VPN endpoint ${VPN_REMOTE}" ; drill -a "${VPN_REMOTE}"
		echo "[debug] Show contents of hosts file" ; cat /etc/hosts
	fi

	# setup ip tables and routing for application
	#source /root/iptable.sh

	# start openvpn tunnel
	#source /root/openvpn.sh

fi
