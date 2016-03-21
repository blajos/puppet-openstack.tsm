class p_libvirt::cluster (
  $cluster_name='libvirt',
  $port=5405,
  $cluster_netname,
  $multicast_address='239.1.1.2',
  $votequorum_expected_votes=2
){
  # FIXME
  class {"p_libvirt":
    cluster_name => $cluster_name
  }

  $publicif=$netname_to_interface[$cluster_netname]

  class { 'corosync':
    enable_secauth    => true,
    authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
    bind_address      => getvar("ipaddress_$publicif"),
    multicast_address => $multicast_address,
    votequorum_expected_votes => $votequorum_expected_votes,
    port => $port,
  }

  corosync::service { 'pacemaker':
    version => '0',
  }

  @@firewall{"100 allow p_libvirt::cluster from $fqdn corosync":
    source => getvar("ipaddress_$publicif"),
    proto => "udp",
    dport => $port,
    action => accept,
    tag => ["p_libvirt::cluster","$cluster_name"],
  }
  Firewall<<| tag=="p_libvirt::cluster" and tag=="$cluster_name" |>>
}
