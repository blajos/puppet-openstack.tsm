class roles::puppetmaster {
  include roles::common

  include p_firewall::server

  include p_puppetmaster
  include p_puppetmaster::maas_client
}

