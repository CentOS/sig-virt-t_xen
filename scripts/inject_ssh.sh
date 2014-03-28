#!bin/bash
# grab a qcow2 image, and and inject the sshkey specified in $2 for /root
# lots os assumptions being made here
# - no lvm is used inside image
# - root fs is on the part 2, with part 1 being /boot
# Remember to give us the entire / complete path to the image file

Img=${1}
PubKey=${2}
Qemu="/usr/lib/xen/bin/qemu-nbd"
probe="/sbin/partprobe"

lsmod | grep  -q nbd 
if [ $? -eq 1 ]; then
	# check this kernel can nbd
	modinfo nbd > /dev/null 2>&1
	if [ $? -eq 0 ]; then
		modprobe nbd max_part=16
	else
		echo 'Need nbd support in kernel'
		exit 1
	fi
fi
if [ ! -e ${Qemu}  ]; then echo 'we need xen4centos installed'; exit 1 ; fi
if [ ! -e ${probe} ]; then echo 'we need parted installed'; exit 1 ; fi

# now lets actually do something
d=$(mktemp -d)

${Qemu} -c /dev/nbd0 ${1} 
${probe} /dev/nbd0
mount /dev/nbd0p2 ${d}
if [ $? -eq 0 ]; then
	mkdir -m 700 ${d}/root/.ssh
	echo ${2} >> ${d}/root/.ssh/authorized_keys
	chmod 600 ${d}/root/.ssh/authorized_keys
	# lazy 
	echo "restorecon -R /root/.ssh" >> ${d}/etc/rc.d/rc.local
fi
umount ${d}
${Qemu} -d ${1}
exit 0