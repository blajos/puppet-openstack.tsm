class p_libvirt (
  $cluster_name="libvirt",
  $vms={}
) {
  ensure_packages(["libvirt-bin", "qemu-kvm", "qemu"])

  #FIXME remote access from other nodes

  p_ceph::client {$cluster_name:}

  create_resources(p_libvirt::vm,$vms)

  file {"/usr/local/bin/create-ceph-secret.sh":
    ensure => present,
    mode => "755",
    source => "puppet:///modules/p_libvirt/create-ceph-secret.sh"
  } ->
  exec {"create ceph secret":
    path => "/usr/bin:/bin",
    unless => "sh -c \"virsh secret-list | grep \\\"client.$cluster_name\\\"\"",
    command => "/usr/local/bin/create-ceph-secret.sh $cluster_name ${::p_ceph::clients[$cluster_name]['key']}",
  }

  file {"/etc/libvirt/vms":
    ensure => directory
  }

  file {"/usr/local/bin/create-vm.sh":
    ensure => present,
    mode => "0755",
    source => "puppet:///modules/p_libvirt/create-vm.sh"
  }
  file {"/usr/local/bin/test-vm.sh":
    ensure => link,
    target => "create-vm.sh",
  }

  create_resources(p_libvirt::vm,$vms)
}
