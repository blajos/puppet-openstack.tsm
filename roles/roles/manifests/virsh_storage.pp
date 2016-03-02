class roles::virsh_storage {
  include roles::common
  include p_firewall::server

  include p_ceph::osd
  include p_libvirt::cluster
}
