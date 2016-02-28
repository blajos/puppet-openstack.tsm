class p_ssh (
  $moduli_limit=2000
){
  $options=hiera_hash("p_ssh::options")

  create_resources(sshd_config,$options,{ensure => present})

  service { "ssh":
    ensure => running,
    enable => true
  }

  Sshd_Config {
    notify => Service["ssh"]
  }

  @@sshkey { "$fqdn":
    ensure       => present,
    type         => "ssh-rsa",
    key          => $sshrsakey,
    host_aliases => [ "$hostname", "$ipaddress" ],
  }

  Sshkey <<||>>


  # Authorized_keys
  $root_keys=hiera_hash("p_ssh::root_keys")
  create_resources(ssh_authorized_key,$root_keys,
    { ensure => present,
      type => "ssh-rsa",
      user => "root"
    })

  
  # Secure /etc/ssh/moduli
  exec { "remove moduli <= $moduli_limit bit":
    command => "awk \"\\\$5 > $moduli_limit\" /etc/ssh/moduli > /tmp/moduli && mv /tmp/moduli /etc/ssh/moduli",
    unless  => "test \$(awk \"\\\$5 <= $moduli_limit\" /etc/ssh/moduli | wc -l) -eq 0",
    path    => [ '/bin', '/usr/bin' ],
  }

}
