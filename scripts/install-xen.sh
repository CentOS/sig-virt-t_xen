#!/bin/bash
# a small script to install xen

yum -y install centos-release-xen
yum -y install xen 
/usr/bin/grub-bootxen.sh