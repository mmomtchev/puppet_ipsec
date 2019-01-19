class ipsec::vpn (
  Hash $vpnconf = {},
  String $vpnname = ''
) {
  Firewall {
    require => undef,
  }

  firewall { '06 accept vpn traffic':
    proto       => 'all',
    destination => '192.168.0.0/16',
    source      => '192.168.0.0/16',
    action      => 'accept',
  }
  firewall { '07 accept related established rules':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    action => 'accept',
  }
  firewall_multi { '09 accept ntp rule':
    dport  => 123,
    proto  => 'udp',
    action => 'accept',
    provider => [ 'iptables', 'ip6tables' ]
  }
  firewall_multi { '10 accept ISAKMP rule':
    dport  => 500,
    source => map($vpnconf) |$k,$v| { $v["ip"] },
    proto  => 'udp',
  }
  firewall_multi { '11 accept ESP rule':
    source => map($vpnconf) |$k,$v| { $v["ip"] },
    proto  => 'esp',
  }
}
