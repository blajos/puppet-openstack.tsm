if $enc_role {
  $role=$enc_role
}
else {
  $role=hiera('role')
}

$master_password=hiera('master_password')

$netname_to_interface=hiera('netname_to_interface')

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
