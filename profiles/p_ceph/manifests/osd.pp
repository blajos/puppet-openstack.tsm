class p_ceph::osd (
  $bootstrap_osd_key,
  $osd_disks
){
  include p_ceph

  create_resources(ceph::osd,$osd_disks)

  ceph::key {'client.bootstrap-osd':
    keyring_path => '/var/lib/ceph/bootstrap-osd/ceph.keyring',
    secret       => $bootstrap_osd_key,
  }
  @@ceph::key { "client.bootstrap-osd-$hostname":
    secret  => $bootstrap_osd_key,
    cap_mon => 'allow profile bootstrap-osd',
  }
  @@firewall { "100 allow p_ceph::osd from $fqdn":
    source => getvar("ipaddress_${$::p_ceph::publicif}"),
    dport => 6789,
    proto  => "tcp",
    action => accept,
    tag => "ceph-mon"
  }

  @@firewall {"100 allow p_ceph::osd from $fqdn public":
    source => getvar("ipaddress_${$::p_ceph::publicif}"),
    proto => "tcp",
    dport => "6800-6850",
    action => accept,
    tag => "ceph-osd"
  }

  @@firewall {"100 allow p_ceph::osd from $fqdn cluster":
    source => getvar("ipaddress_${$::p_ceph::clusterif}"),
    proto => "tcp",
    dport => "6800-6850",
    action => accept,
    tag => "ceph-osd"
  }
  
  Firewall<<| tag == "ceph-osd" |>>

}
