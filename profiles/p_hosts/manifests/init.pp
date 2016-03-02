class p_hosts {
  Host<<||>>

# This is handled by DNS
#  @@host{"$fqdn":
#    ensure => present,
#    ip => $ipaddress,
#    host_aliases => $hostname
#  }
  
  $netnames=keys($::netname_to_interface)
  p_hosts::helper {$netnames:}
}

define p_hosts::helper {
  $ifname=$netname_to_interface["$name"]

  if member(split($::interfaces,","),$ifname) {
    @@host{"${hostname}-${name}.$domain":
      ensure => present,
      ip => getvar("ipaddress_${ifname}"),
      host_aliases => "${hostname}-${name}"
    }
  }
}
