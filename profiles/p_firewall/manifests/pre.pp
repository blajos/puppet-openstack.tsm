class p_firewall::pre {
    Firewall {
      require => undef,
    }

    # Default firewall rules
    firewall { '0000 drop insecure icmp packets 5':
      proto  => 'icmp',
      icmp => '5',
      action => 'drop',
    }->
    firewall { '0000 drop insecure icmp packets 14':
      proto  => 'icmp',
      icmp => '14',
      action => 'drop',
    }->
    firewall { '0000 drop insecure icmp packets 18':
      proto  => 'icmp',
      icmp => '18',
      action => 'drop',
    }->
    firewall { '0000 drop insecure icmp packets 16':
      proto  => 'icmp',
      icmp => '16',
      action => 'drop',
    }->
    firewall { '0009 allow secure icmp packets 0':
      proto  => 'icmp',
      icmp => '0',
      action => 'accept',
    }->
    firewall { '0009 allow secure icmp packets 3':
      proto  => 'icmp',
      icmp => '3',
      action => 'accept',
    }->
    firewall { '0009 allow secure icmp packets 8':
      proto  => 'icmp',
      icmp => '8',
      action => 'accept',
    }->
    firewall { '0009 allow secure icmp packets 11':
      proto  => 'icmp',
      icmp => '11',
      action => 'accept',
    }->
    firewall { '0009 allow secure icmp packets 12':
      proto  => 'icmp',
      icmp => '12',
      action => 'accept',
    }->
    firewall { '001 accept all to lo interface':
      proto   => 'all',
      iniface => 'lo',
      action  => 'accept',
    }->
    firewall { '002 reject local traffic not on loopback interface':
      iniface     => '! lo',
      proto       => 'all',
      destination => '127.0.0.1/8',
      action      => 'reject',
    }->
    firewall { '003 accept related established rules':
      proto  => 'all',
      state  => ['RELATED', 'ESTABLISHED'],
      action => 'accept',
    }

    # Default firewall rules ipv6
    # TODO: Accept only icmp rules needed for operation
    firewall { '0000 drop insecure icmp packets 133 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '133',
      action => 'drop',
      provider => 'ip6tables',
    }->
    firewall { '0000 drop insecure icmp packets 134 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '134',
      action => 'drop',
      provider => 'ip6tables',
    }->
    firewall { '0000 drop insecure icmp packets 137 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '137',
      action => 'drop',
      provider => 'ip6tables',
    }->
    firewall { '0009 allow secure icmp packets 1 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '1',
      action => 'accept',
      provider => 'ip6tables',
    }->
    firewall { '0009 allow secure icmp packets 2 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '2',
      action => 'accept',
      provider => 'ip6tables',
    }->
    firewall { '0009 allow secure icmp packets 3 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '3',
      action => 'accept',
      provider => 'ip6tables',
    }->
    firewall { '0009 allow secure icmp packets 4 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '4',
      action => 'accept',
      provider => 'ip6tables',
    }->
    firewall { '0009 allow secure icmp packets 128 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '128',
      action => 'accept',
      provider => 'ip6tables',
    }->
    firewall { '0009 allow secure icmp packets 129 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '129',
      action => 'accept',
      provider => 'ip6tables',
    }->
    firewall { '0009 allow secure icmp packets 135 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '135',
      action => 'accept',
      provider => 'ip6tables',
    }->
    firewall { '0009 allow secure icmp packets 136 ipv6':
      proto  => 'ipv6-icmp',
      icmp => '136',
      action => 'accept',
      provider => 'ip6tables',
    }->
    firewall { '001 accept all to lo interface ipv6':
      proto   => 'all',
      iniface => 'lo',
      action  => 'accept',
      provider => 'ip6tables',
    }->
    firewall { '002 reject local traffic not on loopback interface ipv6':
      iniface     => '! lo',
      proto       => 'all',
      destination => '::1',
      action      => 'reject',
      provider => 'ip6tables',
    }->
    firewall { '003 accept related established rules ipv6':
      proto  => 'all',
      state  => ['RELATED', 'ESTABLISHED'],
      action => 'accept',
      provider => 'ip6tables',
    }
}
