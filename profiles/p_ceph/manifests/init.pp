class p_ceph (
  $fsid,
  $mon_initial_members,
  $mon_host,
  $bootstrap_osd_key,
  $public_netname,
  $cluster_netname
) {
  class { 'ceph::repo': }
  class { 'ceph':
    fsid => $fsid,
    mon_initial_members => $mon_initial_members,
    mon_host => $mon_host,
  }

  $publicif=$netname_to_interface[$::p_ceph::public_netname]
  $clusterif=$netname_to_interface[$::p_ceph::cluster_netname]

}
