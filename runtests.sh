#!/bin/bash

# setup some base expectations
. config

# XXX: Make sure we have enough resources
#      need 4gb of ram and enough disk space

# how do we make sure that this script is going to resume post-reboot ?
# we migth need a goto statement :)

# get xen
. scripts/install-xen.sh

# reboot the machine
# once again, how do we make sure that the script is going to continue


#!/bin/bash

# this is the stage 3 script, here is where the tests get run

# when things are back :: setup a bridge
brctl addbr br1
ip link set dev br1 up
ip addr add dev br1 192.168.10.1/24

cp configs/t_xen-dnsmasq.conf /etc/dnsmasq.d/
service dnsmasq restart
iptables -I INPUT -i br1 -j ACCEPT


for hv in ${VirtType}; do
	for Rel in 5 6; do
		for Arch in 32 64; do
			echo $Rel $Arch
			# get the image
			# setup the config
			#	 start it up
			# run tests
		done
	done
done
