class p_bond_to_ovs (
  $spec_vlans={}
) {
  ensure_packages(["openvswitch-switch","openvswitch-datapath-dkms"])

  # Convert bond<x> interfaces to br<x> ovs interfaces respectively
  # Adding a new bond interface by hand using ifenslave and not ovs wreaks havoc (ie. please don't)

  if $::bonding_interfaces {
    file { "/etc/network/interfaces.new":
      ensure => present,
      content => template("p_bond_to_ovs/interfaces.erb"),
    } ~>
    exec { "ifdown-ifup":
      command => "/sbin/ifdown -a;/bin/mv /etc/network/interfaces.new /etc/network/interfaces;/sbin/ifup -a",
      refreshonly => true
    }
  }
}
