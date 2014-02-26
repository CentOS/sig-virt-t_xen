#!/bin/bash

# This is the script one needs to run in order to execute
# the test suite

TestHost=$1
RemoteCmd="ssh -t ${TestHost} -l root"
# make sure we can login to ${TestHost}

# setup some baseline stuff
${RemoteCmd} "yum -y install centos-release-xen && yum -y install xen"
${RemoteCmd} "yum -y upgrade && yum -y install curl dnsmasq bridge-utils ntpdate openssh-clients rsync nc"
${RemoteCmd} "ntpdate 0.centos.pool.ntp.org"
${RemoteCmd} "/usr/bin/grub-bootxen.sh"
${RemoteCmd} "reboot"

# wait for the machine to come back, we are going to need a timeout for this...
# ... also need to handle the case of machine didnt come back at all
sleep 60
flag=2
while [ $flag -gt 1 ]; do
	ping -c2 ${TestHost} > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		flag=0
		sleep 10
	fi
done

# rsync the entire testsuite up
${RemoteCmd} "mkdir ~/t_xen"
rsync --exclude =".git/*" -PHvar * root@${TestHost}:t_xen/

# run it
${RemoteCmd} "cd t_xen; ./runtests.sh"