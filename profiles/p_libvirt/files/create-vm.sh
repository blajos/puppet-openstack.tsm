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
disknum=0
for disksize in $DISKS;do
  rbd --id $CLUSTER_NAME -p $CLUSTER_NAME ls |fgrep -q $NAME-$disknum || 
  rbd --id $CLUSTER_NAME -p $CLUSTER_NAME create --size $((disksize*1024)) $NAME-$disknum
  disknum=$((disknum+1))
done

# Get secret's UUID
CEPH_SECRET=`virsh secret-list | grep client.$CLUSTER_NAME|sed -e 's/^ *\([^[:blank:]]*\)[[:blank:]].*/\1/'`

MAC="52:54:00:`echo "$CLUSTER_NAME$NAME"|md5sum|sed -e 's/^\(..\)\(..\)\(..\).*/\1:\2:\3/'`"

UUID=`echo "$CLUSTER_NAME$NAME"|shasum|sed -e 's/^\(.\{8\}\)\(.\{4\}\)\(.\{4\}\)\(.\{4\}\)\(.\{12\}\).*/\1-\2-\3-\4-\5/'`

cat > ${FILEBASE}.xml.new << EOF
<domain type='kvm'>
  <name>$NAME</name>
  <uuid>$UUID</uuid>
  <memory unit='GiB'>$MEM</memory>
  <vcpu placement='static'>$VCPU</vcpu>
  <resource>
    <partition>/machine</partition>
  </resource>
  <os>
    <type arch='x86_64' machine='pc-i440fx-trusty'>hvm</type>
    <boot dev='network'/>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <clock offset='utc'/>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <devices>
    <emulator>/usr/bin/kvm-spice</emulator>
EOF

disk=({a..z})

disknum=0
for disksize in $DISKS;do
  cat >> ${FILEBASE}.xml.new << EOF
    <disk type='network' device='disk'>
      <source protocol='rbd' name='$CLUSTER_NAME/$NAME-$disknum'/>
      <auth username='$CLUSTER_NAME'>
        <secret type='ceph' uuid='$CEPH_SECRET'/>
      </auth>
      <target dev='vd${disk[$disknum]}' bus='virtio'/>
    </disk>
EOF
done

cat >> ${FILEBASE}.xml.new << EOF
    <controller type='usb' index='0'>
      <alias name='usb0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pci-root'>
      <alias name='pci.0'/>
    </controller>
    <controller type='ide' index='0'>
      <alias name='ide0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x01' function='0x1'/>
    </controller>
    <interface type='bridge'>
      <mac address='$MAC'/>
      <source bridge='br0'/>
      <virtualport type='openvswitch' />
      <model type='virtio'/>
    </interface>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <graphics type='vnc' port='-1' autoport='yes' listen='127.0.0.1'>
      <listen type='address' address='127.0.0.1'/>
    </graphics>
    <video>
      <model type='cirrus' vram='9216' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0'/>
    </memballoon>
  </devices>
</domain>
EOF

cleanup(){
  rm -f ${FILEBASE}.xml.new
}

trap cleanup EXIT

if diff -q ${FILEBASE}.xml.new ${FILEBASE}.xml > /dev/zero;then
  if [ "`basename $0`" == "test-vm.sh" ];then
    exit 0
  fi
else    
  if [ "`basename $0`" == "test-vm.sh" ];then
    exit 1
  else
    mv ${FILEBASE}.xml.new ${FILEBASE}.xml
    virsh define ${FILEBASE}.xml
  fi
fi

