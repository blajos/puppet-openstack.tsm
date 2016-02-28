class p_puppetmaster::maas_client (
  $token,
  $server
) {
  include p_maas

  file {"/usr/local/bin/maas_enc.sh":
    ensure => present,
    owner => "root",
    group => "puppet",
    mode => "750",
    content => template("p_puppetmaster/maas_enc.sh.erb")
  }
  ensure_packages("maas-cli")
}

