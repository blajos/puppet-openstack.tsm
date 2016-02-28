class roles::maas {
  include roles::common

  include p_maas::regioncontroller
  include p_maas::clustercontroller

  include p_firewall::server
}

