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

cat  configs/t_xen-dnsmasq.conf  >> /etc/dnsmasq.conf
service dnsmasq restart
iptables -I INPUT -i br1 -j ACCEPT

# we need to set selinux off for now ( reconfirm?)
/usr/sbin/setenforce 0

# stop xend, since we are going to use xl
/sbin/service xend stop

for hv in ${VirtType}; do
    for Rel in ${Releases}; do
        for Arch in ${Arches}; do
            date
            echo 'Going to test : ' $Rel $Arch
            InstName=CentOS-${Rel}-${Arch}-xen-${hv}
            echo curl ${ImgBaseURL}/${Rel}/devel/${InstName}.bz2 
            curl ${ImgBaseURL}/${Rel}/devel/${InstName}.bz2 | bunzip2 > /tmp/c${Rel}-${Arch}-xen-${hv}
            xl destroy "c${Rel}-${Arch}-${hv}" 
            xl create ./configs/${InstName}.xen
            flag=0
            while [ $flag -lt 1 ]; do
                MAC=$(cat ./configs/${InstName}.xen | grep vif | sed -e 's/.*mac=//g' | cut -f1 -d',')
                while [ ! -e /var/lib/dnsmasq/dnsmasq.leases ] || [ `grep ${MAC} /var/lib/dnsmasq/dnsmasq.leases | wc -l ` -lt 1 ]; do
                    echo -n '.'; sleep 1
                done
                IP=$(cat /var/lib/dnsmasq/dnsmasq.leases | grep ${MAC} | cut -f 3 -d\ )
                echo 'Got IP' ${IP}
                sleep 15
                flag=1
            done
            #echo | nc ${IP} 22 | grep SSH > /dev/null 2>&1
            ssh-keyscan ${IP} | grep rsa > /dev/null 2>&1
            Result=$?
            if [ $Result -ne 0 ]; then
                # exit here, leave system state
                exit $Result
            fi
            xl destroy "c${Rel}-${Arch}-${hv}"
            sleep 5
        done
    done
done
