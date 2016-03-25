#!/bin/bash
# $0 cluster_name name mem(GB) vcpu disk1size(GB) disk2size(GB) ...
# Bridged networking to br0
set -ex

CLUSTER_NAME=$1
NAME=$2
MEM=$3
VCPU=$4
shift 4
DISKS="$@"

FILEBASE=/etc/libvirt/vms/$NAME

# Create disks unless they exists
#qemu-img create -f rbd rbd:libvirt-pool/new-libvirt-image 2G
#rbd -p libvirt-pool ls

# Get secret's UUID
CEPH_SECRET=`virsh secret-list | grep client.$CLUSTER_NAME|sed -e 's/^ *\([^[:blank:]]*\)[[:blank:]].*/\1/'`
