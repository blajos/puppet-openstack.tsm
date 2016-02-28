class roles::openstack_db {
  include roles::common

  include p_firewall::server

  #include p_openstack::db
}
