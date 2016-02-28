class p_sysctl {
  $options=hiera_hash("p_sysctl::options")

  create_resources(sysctl,$options,{ensure => present})
}
