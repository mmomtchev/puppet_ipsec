include stdlib
class { 'firewall' : }

$vpnsecrets = [
  'f5717e175434442af16430884dc40f71',
  '97d0cb33f7151fa5f01e103b548504f8',
  'e06199f996c89994f47bc9af907fa22c',
  'ab6805916333f77058122f56caeffc2a',
  '8d9d62594bff33dd7cd407988f7a3ca2',
  '29158dcaacba083a8be4fc47eeb48f79',
]

$vpnconf = {
  'dec'	    => { ip => '1.2.3.4',     vpnnet => '192.168.0.0/20'  },
  'vax'   	=> { ip => '5.6.7.8',     vpnnet => '192.168.16.0/20' },
  'pdp' 		=> { ip => '9.10.11.12',  vpnnet => '192.168.32.0/20' },
  'alpha' 	=> { ip => '13.14.15.16', vpnnet => '192.168.48.0/20' },
}

$vpnlength = length(keys($vpnconf))
$neededlength = $vpnlength * ($vpnlength - 1) / 2
notify{"secrets: ${length($vpnsecrets)}, hosts: ${length(keys($vpnconf))}, should be ${seclength}":}
unless length($vpnsecrets) == $neededlength { 
  fail("${keys($vpnconf)} hosts require ${neededlength} secrets")
}
$all = flatten(keys($vpnconf).map |Integer $i, String $x| {
  $p = keys($vpnconf).map |Integer $j, String $y| {
    { $i => $x , $j => $y }
  }
})
$filt = $all.filter |Integer $i, Hash $x| {
  (length($x) > 1) and ($x.keys[0] < $x.keys[1])
}
$vpnsecretsarray = $filt.map |Integer $i, Hash $x| {
  { a=>values($x)[0], b=>values($x)[1], s=>$vpnsecrets[$i] }
}

Firewall {
  before  => Class['ipsec::post'],
  require => Class['ipsec::pre'],
}

resources { 'firewall':
  purge => true,
}

class { 'ipsec::pre':
  vpnconf => $vpnconf
}

class { 'ipsec::post':
}

node 'alpha' {
  class { 'ipsec::vpn':
    vpnip => '192.168.48.1',
    vpnname => 'alpha',
    vpnconf => $vpnconf,
    vpnsecrets => $vpnsecretsarray,
  }
}

node 'vax' {
  class { 'ipsec::vpn':
    vpnip => '192.168.16.1',
    vpnname => 'vax',
    vpnconf => $vpnconf,
    vpnsecrets => $vpnsecretsarray,
  }
}

node default {
}
