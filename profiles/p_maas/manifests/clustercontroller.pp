class p_maas::clustercontroller (
  $dns_servers = hiera_array("dnsclient::nameservers")
) {
  include p_maas

  ensure_packages(["ipmitool","libvirt-bin"])

  File <<| title == "/root/install/maas-cluster-controller.preseed" |>> ~>
  package{"maas-cluster-controller":
    ensure => present,
    subscribe => Class["p_maas"],
    responsefile => "/root/install/maas-cluster-controller.preseed"
  } ~>
  user{"maas":
    groups => "cansudo"
  }

  include apache
  apache::custom_config { "maas-cluster-http":
    source => "puppet:///modules/p_maas/maas-cluster-http.conf"
  }

  file { "/etc/maas/templates/dhcp/dhcpd.conf.template":
    ensure => present,
    content => template("p_maas/dhcpd.conf.template.erb"),
    owner => "root",
    group => "root",
    mode => "0644",
    require => Package["maas-cluster-controller"]
  }

  firewall { "100 allow dhcp":
    dport   => ["67-69"],
    proto  => "udp",
    action => accept,
  }

  firewall { "100 allow iscsi":
    dport   => ["3260"],
    proto  => "tcp",
    action => accept,
  }

  firewall { "100 allow bootimage access over http":
    dport   => ["80"],
    proto  => "tcp",
    action => accept,
  }

  firewall { "100 allow bootimage access":
    dport   => ["5248"],
    proto  => "tcp",
    action => accept,
  }

  firewall { "100 allow syslog":
    dport   => ["514"],
    proto  => "udp",
    action => accept,
  }

  firewall { "100 allow dhcp ipv6":
    dport   => ["67-69"],
    proto  => "udp",
    action => accept,
    provider => "ip6tables",
  }

  firewall { "100 allow iscsi ipv6":
    dport   => ["3260"],
    proto  => "tcp",
    action => accept,
    provider => "ip6tables",
  }

  firewall { "100 allow bootimage access over http ipv6":
    dport   => ["80"],
    proto  => "tcp",
    action => accept,
    provider => "ip6tables",
  }

  firewall { "100 allow syslog ipv6":
    dport   => ["514"],
    proto  => "udp",
    action => accept,
    provider => "ip6tables",
  }

  # TODO: use later maas version and set up stricter rules
  # https://bugs.launchpad.net/maas/+bug/1352923
  @@firewall { "100 allow $fqdn cluster controller registration":
    source => $::ipaddress,
    dport   => "1024-65535",
    proto  => "tcp",
    action => accept,
    tag => "cluster-controller-registration"
  }

  # Maas vs. ssh to cluster vip address?
  cron {"remove maas known hosts":
    command => "/bin/rm /var/lib/maas/.ssh/known_hosts"
  }
}
