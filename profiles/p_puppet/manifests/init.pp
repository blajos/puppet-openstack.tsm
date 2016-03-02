class p_puppet {
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
