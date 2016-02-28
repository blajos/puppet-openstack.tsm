class roles::openstack_network {
  include roles::common

  include p_firewall::server

  #include p_openstack::network
}
