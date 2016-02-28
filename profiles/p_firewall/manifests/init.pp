class p_firewall {

  $mgmthosts = hiera_array("p_firewall::mgmthosts")

  class { ['p_firewall::pre', 'p_firewall::post']: }

  class { 'firewall': }

  p_firewall::sshhelper{$mgmthosts:}
  
}

define p_firewall::sshhelper {
  if $name =~ /:/ {
    $iptables_provider="ip6tables"
  }
  else {
    $iptables_provider="iptables"
  }

  firewall { "050 allow ssh from $name":
    source => $name,
    dport   => 22,
    proto  => "tcp",
    action => accept,
    provider => $iptables_provider,
  }
}
