class p_firewall::post {
    firewall { '998 log dropped ipv6':
      proto  => 'all',
      jump => 'LOG',
      before => undef,
      log_prefix => "Dropped: ",
      provider => 'ip6tables',
    }

    firewall { '999 drop all ipv6':
      proto  => 'all',
      action => 'drop',
      before => undef,
      provider => 'ip6tables',
    }

    firewall { '998 log dropped':
      proto  => 'all',
      jump => 'LOG',
      before => undef,
      log_prefix => "Dropped: ",
    }

    firewall { '999 drop all':
      proto  => 'all',
      action => 'drop',
      before => undef,
    }
}
