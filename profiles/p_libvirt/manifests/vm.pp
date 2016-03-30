define p_libvirt::vm (
  $vcpu,
  $mem,
  $disks
) {
  $args=sprintf("$::p_libvirt::cluster_name $name $mem $vcpu %s",join($disks," "))

  exec {"/usr/local/bin/create-vm.sh $args":
    unless => "/usr/local/bin/test-vm.sh $args"
  }
}
