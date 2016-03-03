define p_ceph::client {
  include p_ceph

  $key=$::p_ceph::clients[$name]["key"]
  $pool=$::p_ceph::clients[$name]["pool"]

  ceph::key { "client.$name":
    secret  => $key,
    cap_mon => 'allow r',
    cap_osd => "allow rw pool=$pool",
  }

  @@firewall { "100 allow p_ceph::client $name from $fqdn":
    source => getvar("ipaddress_${::p_ceph::publicif}"),
    dport => 6789,
    proto  => "tcp",
    action => accept,
    tag => ["cluster-$::p_ceph::clustername", "ceph-mon"]
  }
}
