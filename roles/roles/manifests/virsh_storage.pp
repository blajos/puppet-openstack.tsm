class roles::virsh_storage {
  include roles::common
  include p_firewall::server

  include p_ceph::osd
  include p_libvirt::cluster

  include p_bond_to_ovs
}
