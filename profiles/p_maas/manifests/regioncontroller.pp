class p_maas::regioncontroller (
  $regioncontroller_ip = $ipaddress,
  $dbhost="localhost",
  $dbpasswordgen,
  $dbport=5432,
  $maas_ip=$ipaddress,
  $adminpassword,
  $is_primary=true
) {
  $dbpassword=sha1("regioncontroller${$dbpasswordgen}${::master_password}")

  include p_maas

  ensure_packages(["maas-dns","maas-region-controller-min"],{subscribe => Class["p_maas"]})

  include ::postgresql::server
  
  if $is_primary {
    postgresql::server::db { "maasdb":
      user     => "maas",
      password => postgresql_password("maas",$dbpassword),
      grant    => 'all',
    }

    @@file{"/root/install/maas-cluster-controller.preseed":
      ensure => present,
      require => File["/root/install"],
      content => "maas-cluster-controller maas-cluster-controller/maas-url string http://$regioncontroller_ip/MAAS
maas-cluster-controller maas-cluster-controller/shared-secret   password        $::maas_shared_secret"
    }
  }

  include apache
  include apache::mod::expires
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::wsgi
  ::apache::mod { 'proxy_wstunnel': }

  apache::custom_config { "maas-http":
    source => "puppet:///modules/p_maas/maas-http.conf"
  }

  file {"/etc/maas/preseeds/curtin_userdata":
    ensure => present,
    owner => "root",
    group => "maas",
    mode => "644",
    source => "puppet:///modules/p_maas/curtin_userdata",
    subscribe => Package["maas-region-controller-min"]
  }

  file {"/etc/maas/maas_local_settings.py":
    ensure => present,
    owner => "root",
    group => "maas",
    mode => "640",
    content => template("p_maas/maas_local_settings.py.erb"),
    subscribe => Package["maas-region-controller-min"],
    notify => Service["apache2"]
  }

  file {"/etc/maas/regiond.conf":
    ensure => present,
    owner => "root",
    group => "maas",
    mode => "640",
    content => "database_host: $dbhost
database_name: maasdb
database_pass: $dbpassword
database_user: maas
maas_url: http://$regioncontroller_ip/MAAS
",
    subscribe => Package["maas-region-controller-min"],
    notify => Service["apache2"]
  }

  if $is_primary {
    #returns 1 if cannot connect
    exec {"maas_syncdb":
      command => "/bin/sh -c '/usr/sbin/maas-region-admin syncdb --noinput && /usr/bin/touch /etc/maas/.stamp-syncdb'",
      creates => "/etc/maas/.stamp-syncdb",
      subscribe => File["/etc/maas/maas_local_settings.py"]
    } ->
    exec {"/bin/sh -c '/usr/sbin/maas-region-admin migrate maasserver --noinput && /usr/bin/touch /etc/maas/.stamp-migrate-maasserver'":
      creates => "/etc/maas/.stamp-migrate-maasserver"
    } ->
    exec {"/bin/sh -c '/usr/sbin/maas-region-admin migrate metadataserver --noinput && /usr/bin/touch /etc/maas/.stamp-migrate-metadataserver'":
      creates => "/etc/maas/.stamp-migrate-metadataserver"
    } ->
    exec {"/bin/sh -c '/usr/sbin/maas-region-admin createadmin --username admin --password $adminpassword --email root@localhost && /usr/bin/touch /etc/maas/.stamp-createadmin'":
      creates => "/etc/maas/.stamp-createadmin"
    }
  }
  else {
    exec {"maas_syncdb":
      command => "/usr/bin/touch /etc/maas/.stamp-syncdb /etc/maas/.stamp-migrate-maasserver /etc/maas/.stamp-migrate-metadataserver /etc/maas/.stamp-createadmin",
      creates => "/etc/maas/.stamp-createadmin",
      subscribe => File["/etc/maas/maas_local_settings.py"]
    }
  }

  firewall { "100 allow dns access":
    dport   => 53,
    proto  => "udp",
    action => accept,
  }

  firewall { "100 allow squid access":
    dport   => [3128,8000],
    proto  => "tcp",
    action => accept,
  }

  firewall { "100 allow maas http access":
    dport   => [80,443],
    proto  => "tcp",
    action => accept,
  }

  firewall { "100 allow dns access ipv6":
    dport   => 53,
    proto  => "udp",
    action => accept,
    provider => "ip6tables",
  }

  firewall { "100 allow squid access ipv6":
    dport   => [3128,8000],
    proto  => "tcp",
    action => accept,
    provider => "ip6tables",
  }

  firewall { "100 allow maas http access ipv6":
    dport   => [80,443],
    proto  => "tcp",
    action => accept,
    provider => "ip6tables",
  }

  file { "/etc/maas/maas-proxy.conf":
    owner => "root",
    group => "root",
    mode => "644",
    content => template("p_maas/maas-proxy.conf.erb"),
    subscribe => Package["maas-region-controller-min"],
    notify => Service["maas-proxy"]
  }~>
  file { ["/usr/lib/squid3/pinger"]:
    mode => "ug-s,o-t",
  }~>
  service { "maas-proxy":
    ensure => running,
    enable => true
  }

  Firewall <<| tag == "cluster-controller-registration" |>>

  ensure_packages("maas-cli")
  file {"/usr/local/bin/maas1.9_node_setup.py":
    ensure => present,
    mode => "0755",
    source => "puppet:///modules/p_maas/maas1.9_node_setup.py"
  }
}
