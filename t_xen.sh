#!/bin/bash

# This is the script one needs to run in order to execute
# the test suite

TestHost=$1
RemoteCmd="ssh -t ${TestHost} "
# make sure we can login to ${TestHost}

# setup some baseline stuff
${RemoteCmd} "yum -y install curl dnsmasq bridge-utils ntpdate openssh-clients"
${RemoteCmd} "ntpdate 0.centos.pool.ntp.org"
${RemoteCmd} "yum -y upgrade"
cat configs/install-xen.cron  | ${RemoteCmd} "crontab -u root -e"
${RemoteCmd} "reboot"

# scp the entire set of files from this dir to there 

# login to the remote machine and run the tests