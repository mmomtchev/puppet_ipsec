class ipsec::vpn (
  String $vpnip = '',
  String $vpnname = '',
  Hash $vpnconf = {},
  Array $vpnsecrets = [],
) {
  include '::network'

  package {'racoon':
    ensure		=> 'latest',
  }

  class { 'ntp':
  }


  /* If dummy interfaces on the VPN network is needed, especially for keeping routes */
  kmod::load { 'dummy': }
  ->
  network_config { 'dummy0':
    ensure			=> 'present',
    family			=> 'inet',
    method			=> 'static',
    onboot			=> 'true',
    netmask			=> '255.255.0.0',
    ipaddress		=> $vpnip,
    notify      => Exec['ifup dummy0']
  }

  exec { 'ifup dummy0': 
    command         => '/sbin/ifup',
    refreshonly     => true,
  }

  file { '/etc/racoon/psk.txt':
    ensure		=> 'present',
    owner			=> 'root',
    group			=> 'root',
    mode			=> '0600',
    content		=> template('ipsec/psk.erb'),
    notify    => [ Service['racoon'], Exec['setkey'] ],
    subscribe => Exec['ifup dummy0']  
  }

  file { '/etc/racoon/racoon.conf':
    ensure		=> 'present',
    owner			=> 'root',
    group			=> 'root',
    mode			=> '0600',
    content		=> template('ipsec/racoon.erb'),
    notify    => [ Service['racoon'], Exec['setkey'] ],
    subscribe => Exec['ifup dummy0']
  }

  file { '/etc/ipsec-tools.conf':
    ensure		=> 'present',
    owner			=> 'root',
    group			=> 'root',
    mode			=> '0600',
    content		=> template('ipsec/setkey.erb'),
    notify    => [ Service['racoon'], Exec['setkey'] ],
    subscribe => Exec['ifup dummy0']
  }

  exec { 'setkey':
    command     => '/etc/init.d/setkey start',
    refreshonly	=> true,
    path			  => [ "/sbin", "/bin", "/usr/sbin", "/usr/bin" ],
    subscribe		=> File["/etc/ipsec-tools.conf"],
  }

  service { "racoon":
    ensure			=> 'running',
    subscribe		=> File["/etc/ipsec-tools.conf", "/etc/racoon/racoon.conf", "/etc/racoon/psk.txt"]
  }
}
