class p_libvirt (
  $cluster_name="libvirt",
  $vms={},
  $vm_autostart=true
) {
  ensure_packages("libvirt-bin")

  #FIXME remote access from other nodes

  p_ceph::client {$cluster_name:}

  create_resources(p_libvirt::vmxml,$vms,{autostart => $vm_autostart})
}
