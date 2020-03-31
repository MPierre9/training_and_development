#!/bin/bash

vgchange -ay # refresh lvm state and check if there are any lvm volumes present

DEVICE_FS=`blkid -o value -s TYPE ${DEVICE}` # Check if DEVICE has a file system 

if [ "`echo -n  $DEVICE_FS`" == "" ] ; then 
        pvcreate ${DEVICE} # initialize a disk for partition for use by LVM
        vgcreate data ${DEVICE} # create a volume group
        lvcreate --name volume1 -l 100%FREE data # create a logical volume in an existing volume group
        mkfs.ext4 /dev/data/volume1 # build a Linux file system
fi

mkdir -p /data
echo '/dev/data/volume1 /data ext4 defaults 0 0' >> /etc/fstab
mount /data

yum install httpd -y
apachectl start
chkconfig --add httpd
chkconfig httpd on
echo "Hello from Terraform" > /var/www/html/index.html