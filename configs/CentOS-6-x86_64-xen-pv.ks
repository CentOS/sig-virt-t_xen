install
url --url=http://mirror.centos.org/centos/6/os/x86_64/
lang en_US.UTF-8
keyboard uk
network --device eth0 --bootproto dhcp
rootpw --iscrypted $1$Ovzco0Wz$1rgKgPid/yimx69AKkP6u0
firewall --service=ssh
authconfig --enableshadow --passalgo=sha512 --enablefingerprint
selinux --enforcing
timezone --utc UTC
bootloader --location=mbr --driveorder=sda
repo --name="CentOS" --baseurl=http://mirror.centos.org/centos/6/os/x86_64/ --cost=100
zerombr yes
clearpart --all --initlabel
part /boot --fstype ext3 --size=250
part / --size=5000 --grow
reboot
%packages
@core
%end
%post --nochroot
sed -i '/HWADDR/d' /mnt/sysimage/etc/sysconfig/network-scripts/ifcfg-eth\*
for f in /boot/grub/grub.conf; do
  /bin/sed -i "s/^serial.*$//" /mnt/sysimage/${f}
  /bin/sed -i "s/^terminal.*$//" /mnt/sysimage/${f}
  /bin/sed -i "s/console=ttyS0,115200/console=hvc0/" /mnt/sysimage/${f}
done
%end