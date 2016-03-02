class p_ceph::client (
  $keyname,
  $key,
  $pool
) {
  include p_ceph

  ceph::key { "client.$keyname-$hostname":
    secret => $key
  }
  @@ceph::key { "client.$keyname-$hostname":
    secret  => $key,
    cap_mon => 'allow r',
    cap_osd => "allow rw pool=$pool",
    before => undef
  }

  @@firewall { "100 allow p_ceph::client from $fqdn":
    source => getvar("ipaddress_$netname_to_interface['ceph']"),
    dport => 6789,
    proto  => "tcp",
    action => accept,
    tag => "ceph-mon"
  }
}
