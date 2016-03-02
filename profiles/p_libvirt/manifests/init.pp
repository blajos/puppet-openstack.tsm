class p_libvirt (
  $cluster_name="libvirt",
  $ceph_pool="libvirt",
  $ceph_key,
  $vms={},
  $vm_autostart=true
) {
  ensure_packages("libvirt-bin")

  #FIXME remote access from other nodes

  p_ceph::client {$cluster_name:
    key => $ceph_key,
    pool => $ceph_pool
  }

  create_resources(p_libvirt::vmxml,$vms,{autostart => $vm_autostart})
}
