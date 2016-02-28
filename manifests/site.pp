$role=hiera('role')
$site=hiera('site')
$master_password=hiera('master_password')

class { "roles::$role": }

resources { 'firewall':
  purge => true,
}

Firewall {
  before  => Class['p_firewall::post'],
  require => Class['p_firewall::pre'],
}

file { "/root/install":
  ensure => directory
}

ensure_packages("vlan")
Package["vlan"] ~> Class["network"]
