#!/bin/bash

# setup some base expectations
. config

# XXX: Make sure we have enough resources
#      need 4gb of ram and enough disk space

# we should also test if a 192 ip exists on the machine, bad things
# could happen if we setup a bridge
brctl addbr br1
ip link set dev br1 up
ip addr add dev br1 192.168.10.1/24

cp configs/t_xen-dnsmasq.conf /etc/dnsmasq.d/
service dnsmasq restart
iptables -I INPUT -i br1 -j ACCEPT

# we need to set selinux off for now ( reconfirm?)
/usr/sbin/setenforce 0

for hv in ${VirtType}; do
#   for Rel in 5 6; do
    for Rel in 6; do
        #for Arch in i386 x86_64; do
        for Arch in x86_64; do
            echo $Rel $Arch
            curl ${ImgBaseURL}/${Rel}/devel/CentOS-${Rel}-${Arch}-xen-${hv}.bz2 | bunzip2 > /tmp/c${Rel}-${Arch}-xen-${hv}
            xl create ./configs/CentOS-${Rel}-${Arch}-xen-${hv}.xen
            flag=0
            while [ $flag - lt 1 ]; do
                # we should really set static mac's in the config files and check for those here, this is a serious hack
                while [ ! -e /var/lib/dnsmasq/dnsmasq.leases || `cat /var/lib/dnsmasq/dnsmasq.leases | wc -l ` -lt 1 ]; do
                    sleep 1
                done
                IP=$(cat cat /var/lib/dnsmasq/dnsmasq.leases | tail -n1 | cut -f 3 -d\ )
                sleep 5
            done
            echo | nc ${IP} 22 | grep SSH > /dev/null 2>&1
            Result=$?
            xl destroy "c${Rel}-${Arch}-${hv}"
            sleep 5
        done
    done
done

# this is only going to give us the result for the last VM instantiated
# maybe we want to not run all of them in 1 script, but have Jenkins
# start one test run per Image we want to test(?)
exit $Result
