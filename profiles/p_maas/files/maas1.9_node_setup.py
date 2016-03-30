#!/usr/bin/env python

import subprocess
import yaml
import re

def run(command):
  print command
  output=subprocess.check_output(command.split(" "))
  return yaml.load(output)

systems=map(lambda node: node["system_id"], run("maas local nodes list"))

try:
  run("maas local tags new name=maas_setup_complete")
except:
  pass

complete_systems=map(lambda node: node["system_id"], run("maas local tag nodes maas_setup_complete"))
incomplete_systems=filter(lambda system_id: not complete_systems.count(system_id), systems)

for system in incomplete_systems:
  # Partitition first disk
  ## Clean existing partitions
  vgs=run("maas local volume-groups read "+system)
  for vg in vgs:
    lvs=vg["logical_volumes"]
    for lv in lvs:
      run("maas local volume-group delete-logical-volume "+system+" "+str(vg["id"])+" id="+str(lv["id"]))

    run("maas local volume-group delete "+system+" "+str(vg["id"]))

  disks=run("maas local block-devices read "+system)
  sda=filter(lambda disk: re.match("[sv]d",disk["name"]), disks)
  sda=sda[0]
  sda_id=str(sda["id"])
  parts=run("maas local partitions read "+system+" "+sda_id)
  for part in parts:
    run("maas local partition delete "+system+" "+sda_id+" "+str(part["id"]))

  ## Create partitions
  root_part=run("maas local partitions create "+system+" "+sda_id+" size=10000000000 bootable=true")
  rest_of_disk=run("maas local block-device read "+system+" "+sda_id)
  rest_of_disk=rest_of_disk["available_size"]
  pv_part=run("maas local partitions create "+system+" "+sda_id+" size="+str(rest_of_disk))

  # Create fs on first part
  run("maas local partition format "+system+" "+sda_id+" "+str(root_part["id"])+" fstype=ext4")
  run("maas local partition mount "+system+" "+sda_id+" "+str(root_part["id"])+" mount_point=/")

  # Create pv, vg on second part
  vg=run("maas local volume-groups create "+system+" name=os partitions="+str(pv_part["id"]))

  # Create /var and /var/log
  lv_params={
    "var": {
      "size": 5000000000,
      "mp": "/var"
    },
    "var+log": {
      "size": 5000000000,
      "mp": "/var/log"
    }
  }
  for name,params in lv_params.iteritems():
    part=run("maas local volume-group create-logical-volume "+system+" "+str(vg["id"])+" name="+name+" size="+str(params["size"]))
    run("maas local block-device format "+system+" "+str(part["id"])+" fstype=ext4")
    run("maas local block-device mount "+system+" "+str(part["id"])+" mount_point="+params["mp"])

  # Remove existing bond and vlan interfaces
  to_remove_interfaces=filter(lambda intf: intf["parents"], run("maas local interfaces read "+system))
  for intf in sorted(to_remove_interfaces,key=lambda intf: intf["id"], reverse=True):
    run("maas local interface delete "+system+" "+str(intf["id"]))

  # Create bond interface
  interfaces=filter(lambda intf: not intf["parents"], run("maas local interfaces read "+system))
  parentstring=" ".join(map(lambda intf: "parents="+str(intf["id"]), interfaces))
  bond=run("maas local interfaces create-bond "+system+" name=bond0 "+parentstring+" vlan=0 bond_mode=active-backup")
  subnets=run("maas local subnets read")
  subnets_with_vlan0=filter(lambda subnet: subnet["vlan"]["vid"]==0, subnets)
  run("maas local interface link-subnet "+system+" "+str(bond["id"])+" mode=AUTO subnet="+str(subnets_with_vlan0[0]["id"]))
  
  # Create VLANS
  vlans=filter(lambda vlan: vlan["vid"], run("maas local vlans read 0"))
  for vlan in vlans:
    intf=run("maas local interfaces create-vlan "+system+" parent="+str(bond["id"])+" vlan="+str(vlan["id"]))
    subnets_with_vlanx=filter(lambda subnet: subnet["vlan"]["vid"]==vlan["vid"], subnets)
    run("maas local interface link-subnet "+system+" "+str(intf["id"])+" mode=AUTO subnet="+str(subnets_with_vlanx[0]["id"]))

  run("maas local tag update-nodes maas_setup_complete add="+system)
