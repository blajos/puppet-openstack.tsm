class p_firewall::server {
  include p_firewall

  firewall { '982 accept all (local packets are already dropped)':
    proto  => 'all',
    action => 'accept',
  }

  $ainterfaces=split($::interfaces,",")
  p_firewall::server::helper{$ainterfaces: }
}

define p_firewall::server::helper {
  if inline_template("<%= @network_$name %>") and $name!="lo" {
    firewall { "980 log locally dropped on $name":
      proto  => 'all',
      source => inline_template("<%= @network_$name %>/<%= @netmask_$name %>"),
      jump => 'LOG',
      log_prefix => "Dropped local on $name: ",
    }
    firewall { "981 drop on $name local":
      proto  => 'all',
      source => inline_template("<%= @network_$name %>/<%= @netmask_$name %>"),
      action => 'drop'
    }
  }
}
