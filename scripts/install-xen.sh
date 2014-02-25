#!/bin/bash
# a small script to install xen
if [ ! -e /tmp/installed-xen ]; then
	yum -y install centos-release-xen
	yum -y install xen 
	/usr/bin/grub-bootxen.sh
	touch /tmp/installed-xen
fi