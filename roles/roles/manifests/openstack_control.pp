class roles::openstack_control {
  include roles::common

  include p_firewall::server

  #include p_ceph::mon
  #include p_openstack::control
}

