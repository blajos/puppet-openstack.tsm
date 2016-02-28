class p_security::suid {
  ensure_packages(["at", "fuse", "liblockfile-bin", "mlocate", "policykit-1", "ppp", "screen", "mtr-tiny"],{
    ensure => absent,
  })

  file { ["/usr/bin/bsd-write", "/usr/bin/wall", "/usr/bin/crontab", "/usr/lib/dbus-1.0/dbus-daemon-launch-helper", "/usr/lib/eject/dmcrypt-get-device", "/bin/ping", "/bin/ping6", "/usr/bin/traceroute6.iputils", "/usr/lib/pt_chown", "/sbin/unix_chkpwd", "/bin/su", "/usr/bin/newgrp", "/bin/mount", "/bin/umount", "/usr/bin/ssh-agent", "/usr/lib/openssh/ssh-keysign", "/usr/bin/chage", "/usr/bin/chfn", "/usr/bin/chsh", "/usr/bin/expiry", "/usr/bin/gpasswd", "/usr/bin/passwd"]:
    mode => "ug-s,o-t"
  }

  group { "cansudo":
    ensure => present,
    system => true
  } ~>
  file { "/usr/bin/sudo":
    mode => "4750",
    group => "cansudo"
  } ~>
  exec { "/usr/bin/dpkg-statoverride --add root cansudo 4750 /usr/bin/sudo":
    refreshonly => true
  }
}
