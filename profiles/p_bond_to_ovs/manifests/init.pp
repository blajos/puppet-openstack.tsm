class p_bond_to_ovs (
  $spec_vlans={}
) {
  # Convert bond<x> interfaces to br<x> ovs interfaces respectively

  exec { "ifdown":
    command => "/sbin/ifdown -a",
    refreshonly => true
  } ~>
  exec { "ifup":
    command => "/sbin/ifup -a",
    refreshonly => true
  }

  file { "/etc/network/interfaces":
    ensure => present,
    content => template("p_bond_to_ovs/interfaces.erb"),
    require => Exec["ifdown"],
    notify => Exec["ifup"]
  }
}
