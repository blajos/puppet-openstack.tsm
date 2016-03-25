class roles::common {
  include p_ssh
  include p_sysctl
  include p_firewall
  include p_puppet
  include p_hosts
  include network
  include dnsclient
  include lvm
  include p_security::suid
  include apt
  include ntp
}
