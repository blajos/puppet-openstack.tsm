class p_ceph::osd (
  $osd_disks
){
  include p_ceph

  create_resources(ceph::osd,$osd_disks,{cluster => $::p_ceph::clustername})

  ceph::key {'client.bootstrap-osd':
    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    secret       => $::p_ceph::bootstrap_osd_key,
  }
  @@firewall { "100 allow p_ceph::osd from $fqdn":
    source => getvar("ipaddress_${::p_ceph::publicif}"),
    dport => 6789,
    proto  => "tcp",
    action => accept,
    tag => ["cluster-$::p_ceph::clustername", "ceph-mon"]
  }

  @@firewall {"100 allow p_ceph::osd from $fqdn public":
    source => getvar("ipaddress_${::p_ceph::publicif}"),
    proto => "tcp",
    dport => "6800-6850",
    action => accept,
    tag => ["cluster-$::p_ceph::clustername", "ceph-osd"]
  }

  @@firewall {"100 allow p_ceph::osd from $fqdn cluster":
    source => getvar("ipaddress_${::p_ceph::clusterif}"),
    proto => "tcp",
    dport => "6800-6850",
    action => accept,
    tag => ["cluster-$::p_ceph::clustername", "ceph-osd"]
  }
  
  Firewall<<| tag == "ceph-osd" and tag == "cluster-$::p_ceph::clustername" |>>

}
