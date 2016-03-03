class p_libvirt::cluster (
  $cluster_netname,
  $multicast_address='239.1.1.2'
){
  # FIXME
  include p_libvirt

  $publicif=$netname_to_interface[$cluster_netname]

  class { 'corosync':
    enable_secauth    => true,
    authkey           => '/var/lib/puppet/ssl/certs/ca.pem',
    bind_address      => getvar("ipaddress_$publicif"),
    multicast_address => $multicast_address,
  }

  corosync::service { 'pacemaker':
    version => '0',
  }

}
