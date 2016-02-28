class p_puppetmaster (
  $ports=[8140,8081]
){
      ensure_packages(["puppet", "puppetmaster", "git", "make"])

      $puppetlabs_release = "puppetlabs-release-trusty.deb"
      $puppetlabs_release_package = "puppetlabs-release"

      exec { "/usr/bin/wget -O /root/install/$puppetlabs_release https://apt.puppetlabs.com/$puppetlabs_release":
        creates => "/root/install/$puppetlabs_release",
	require => File["/root/install"]
      } ~>
      package { $puppetlabs_release_package:
        provider => "dpkg",
        source => "/root/install/$puppetlabs_release",
        before => [Class['puppetdb'], Class['puppetdb::master::config']],
        notify => Exec["apt_update"]
      }
      
      # Configure puppetdb and its underlying database
      class { 'puppetdb': 
        manage_dbserver => false,
      }
      # Configure the puppet master to use puppetdb
      class { 'puppetdb::master::config': }
      include ::postgresql::server
      
      #if defined($::p_postgres_cluster::vip) {
#	::pgpool::pool_passwd { "puppetdb":
#	  password_hash => postgresql_password("puppetdb","puppetdb"),
#	}
#
#	::pgpool::hba { 'puppetdb_md5_from_pgpoolvip':
#	  type        => 'host',
#	  database    => 'puppetdb',
#	  user        => 'puppetdb',
#	  address     => "$::p_postgres_cluster::vip/32",
#	  auth_method => 'md5',
#	}
#	@@::pgpool::hba { 'puppetdb_md5_from_$fqdn':
#	  type        => 'host',
#	  database    => 'puppetdb',
#	  user        => 'puppetdb',
#	  address     => "$ipaddress/32",
#	  auth_method => 'md5',
#	  tag => "puppetdb",
#	}
#	Pgpool::Hba<<|tag=="puppetdb"|>>
#      }

      firewall { "100 allow puppetmaster and puppetdb access":
        dport => $ports,
        proto => "tcp",
        action => accept,
      }
      
      firewall { "100 allow puppetmaster and puppetdb access ipv6":
        dport => $ports,
        proto => "tcp",
        action => accept,
        provider => "ip6tables",
      }

      file { "/etc/puppet":
        ensure => directory,
        owner => "root",
        group => "puppet",
        mode => "g+r,o-rwx",
        recurse => true,
        subscribe => Package["puppetmaster"]
      }

      file { "/var/lib/puppet/reports":
        ensure => directory,
        owner => "puppet",
        group => "puppet",
        mode => "o-rwx",
        recurse => true,
        subscribe => Package["puppetmaster"]
      }

  @@host{"puppet":
    ensure => present,
    ip => $ipaddress,
  }

  package { ['hiera-eyaml', 'deep_merge']:
    ensure   => present,
    provider => gem,
  }

#TODO: /var/lib/puppet mappa tartalmat karban kell tartani, pl
#find /var/lib/puppet/reports/ -mtime +1 -type f|xargs rm
}   
