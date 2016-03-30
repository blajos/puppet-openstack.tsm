class p_libvirt::cluster (
  $cluster_name='libvirt',
  $port=5405,
  $cluster_netname,
  $multicast_address='239.1.1.2',
  $votequorum_expected_votes=2,
  $rgs={}, #Resource groups
){
  class {"p_libvirt":
    cluster_name => $cluster_name
  }

  $clusterif=$netname_to_interface[$cluster_netname]

  if getvar("ipaddress_$clusterif") {
    class { 'corosync':
      enable_secauth    => true,
      authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
      bind_address      => getvar("ipaddress_$clusterif"),
      multicast_address => $multicast_address,
      votequorum_expected_votes => $votequorum_expected_votes,
      port => $port,
      debug => true,
    }

    corosync::service { 'pacemaker':
      version => '0',
    }

    cs_property { 'stonith-enabled' :
      value   => 'false',
    }

    @@firewall{"100 allow p_libvirt::cluster from $fqdn corosync":
      source => getvar("ipaddress_$clusterif"),
      proto => "udp",
      dport => $port,
      action => accept,
      tag => ["p_libvirt::cluster","$cluster_name"],
    }
    Firewall<<| tag=="p_libvirt::cluster" and tag=="$cluster_name" |>>

    create_resources(p_libvirt::cluster::rg,$rgs)
  }
}
