class p_puppet {
  #Host<<| title=="puppet" |>>
  Host<<||>>
  @@host{"$fqdn":
    ensure => present,
    ip => $ipaddress,
    host_aliases => $hostname
  }

  package {"puppet":
    ensure => present,
  }~>
  file {"/etc/default/puppet":
    ensure => present,
    content => "START=yes
DAEMON_OPTS=\"\"
",
  }~>
  service {"puppet":
    ensure => running,
    enable => true
  }

}
