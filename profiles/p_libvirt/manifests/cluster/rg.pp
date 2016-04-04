define p_libvirt::cluster::rg(
  $vms={}
) {
  $vip=$name

  cs_primitive { "vip_$name":
    primitive_class => 'ocf',
    primitive_type  => 'IPaddr2',
    provided_by     => 'heartbeat',
    parameters      => { 'ip' => "$vip", 'cidr_netmask' => '32' },
    operations      => { 'monitor' => { 'interval' => '10s' } },
  }

  create_resources(p_libvirt::cluster::rg::vm,$vms,{vip => $vip})

}

define p_libvirt::cluster::rg::vm (
  $vcpu,
  $mem,
  $disks,
  $deployed="FALSE",
  $vip
){
  p_libvirt::vm{"$name":
    vcpu => $vcpu,
    mem => $mem,
    disks => $disks
  }

  cs_primitive { "vm_$name":
    primitive_class => 'ocf',
    primitive_type  => 'VirtualDomain',
    provided_by     => 'heartbeat',
    promotable      => true,
    metadata        => { 'is-managed' => $deployed },
    parameters      => { 'config' => "/etc/libvirt/vms/$name.xml" },
    operations      => { 'monitor' => { 'interval' => '10s' } },
    require => P_libvirt::Vm["$name"],
  } ~>
  cs_colocation { "${name}_to_${vip}":
    primitives => ["vip_$vip", "ms_vm_$name"],
    score => '1000',
    require => Cs_primitive["vip_$vip"]
  }
}
