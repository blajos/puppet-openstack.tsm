class p_ceph::mon (
  $admin_key,
  $mon_key,
){
  include p_ceph

  $instancename="${::hostname}-$::p_ceph::public_netname"

  ceph::mon { "$instancename":
    public_addr => getvar("ipaddress_${$::p_ceph::publicif}"),
    key => $mon_key,
  }

  Ceph::Key {
    inject         => true,
    inject_as_id   => 'mon.',
    inject_keyring => "/var/lib/ceph/mon/ceph-${instancename}/keyring",
  }

  ceph::key { 'client.admin':
    secret  => $admin_key,
    cap_mon => 'allow *',
    cap_osd => 'allow *',
    cap_mds => 'allow',
  }

  ceph::key { "client.bootstrap-osd":
    secret  => $::p_ceph::bootstrap_osd_key,
    cap_mon => 'allow profile bootstrap-osd',
  }
  
  Ceph::Key <<||>>

  @@firewall { "100 allow p_ceph::mon from $fqdn":
    source => getvar("ipaddress_${$::p_ceph::publicif}"),
    dport => 6789,
    proto  => "tcp",
    action => accept,
    tag => "ceph-mon"
  }
  Firewall<<| tag == "ceph-mon" |>>
  
}
