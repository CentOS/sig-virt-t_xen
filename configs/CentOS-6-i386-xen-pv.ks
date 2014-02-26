#
# This is a very basic ks, it -really- needs to be trimmed down
# from the 320MB qcow2 it results in to ~ 120MB
# 
# if we are going to run tests inside the VM ( we should) then
# there would be a need to also inject a ssh pubkey at image
# build time, so would need to go here in the ks
#
install
url --url=http://mirror.centos.org/centos/6/os/i386/
lang en_US.UTF-8
keyboard uk
network --device eth0 --bootproto dhcp
rootpw --iscrypted $1$Ovzco0Wz$1rgKgPid/yimx69AKkP6u0
firewall --service=ssh
authconfig --enableshadow --passalgo=sha512 --enablefingerprint
selinux --enforcing
timezone --utc UTC
bootloader --location=mbr --driveorder=sda
repo --name="CentOS" --baseurl=http://mirror.centos.org/centos/6/os/i386/ --cost=100
zerombr yes
clearpart --all --initlabel
part /boot --fstype ext3 --size=250
part / --size=5000 --grow
reboot
%packages
@core
%end
%post
/bin/sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-eth\*
/bin/sed -i "s/^serial.*$//" /boot/grub/grub.conf
/bin/sed -i "s/^terminal.*$//" /boot/grub/grub.conf
/bin/sed -i "s/console=ttyS0,115200/console=hvc0/" /boot/grub/grub.conf
%end