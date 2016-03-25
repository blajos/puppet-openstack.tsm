class p_ceph (
  $fsid,
  $mon_initial_members,
  $mon_host,
  $bootstrap_osd_key,
  $public_netname,
  $cluster_netname,
  $clustername="ceph",
  $clients={},
  $debug=undef
) {
  class { 'ceph::repo': }
  class { 'ceph':
    fsid => $fsid,
    mon_initial_members => $mon_initial_members,
    mon_host => $mon_host,
  }

  $publicif=$netname_to_interface[$::p_ceph::public_netname]
  $clusterif=$netname_to_interface[$::p_ceph::cluster_netname]

  if $debug {
    ceph_config {
      "global/debug ms": value => "1/5";
      "mon/debug mon": value => "20";
      "mon/debug paxos": value => "1/5";
      "mon/debug auth": value => "2";
      "osd/debug osd": value => "1/5";
      "osd/debug filestore": value => "1/5";
      "osd/debug journal": value => "1";
      "osd/debug monc": value => "5/20";
    }
  }
  else {
    ceph_config {
      "global/debug ms": ensure => absent;
      "mon/debug mon": ensure => absent;
      "mon/debug paxos": ensure => absent;
      "mon/debug auth": ensure => absent;
      "osd/debug osd": ensure => absent;
      "osd/debug filestore": ensure => absent;
      "osd/debug journal": ensure => absent;
      "osd/debug monc": ensure => absent;
    }
  }
}
