# Gateway Aarhus
class { 
  'ffnord::params':
    router_id => "5.186.50.156", # The id of this router, probably the ipv4 address
                              # of the mesh device of the providing community
    icvpn_as => "64879",      # The as of the providing community
    wan_devices => ['eth0'],   # A array of devices which should be in the wan zone

    # wmem_default => 87380,     # Define the default socket send buffer
    # wmem_max     => 12582912,  # Define the maximum socket send buffer
    # rmem_default => 87380,     # Define the default socket recv buffer
    # rmem_max     => 12582912,  # Define the maximum socket recv buffer

    #max_backlog  => 5000,      # Define the maximum packages in buffer
}

# You can repeat this mesh block for every community you support
ffnord::mesh { 
  'mesh_ffgc':
    mesh_name    => "Freemesh Denmark",
    mesh_code    => "fmdk",
    mesh_as      => 64879,
    mesh_mac     => "de:ad:be:ef:de:ad",
    vpn_mac      => "de:ad:be:ff:de:ad",
    mesh_ipv6    => "fd35:f308:a922::ff00/64",
    mesh_ipv4    => "10.212.0.1/21",
    mesh_mtu     => "1280",
    range_ipv4   => "10.212.0.0/20",
    mesh_peerings => "/root/mesh_peerings.yaml",

    fastd_secret => "/root/fastd_secret.key",
    fastd_port   => 11280,
    fastd_peers_git => 'git://github.com/Freemesh-Denmark/peers.git',

    # the whole net: 10.212.0.1 - 10.212.15.254
    dhcp_ranges => [ '10.212.0.2 10.212.2.254'],
    dns_servers => [ '10.212.0.1'
                   , '10.212.3.1'
                   , '10.212.6.1'
                   , '10.212.9.1'
                   , '10.212.12.1'
                   ]
}

ffnord::named::zone {
  'fmdk': zone_git => 'git://github.com/Freemesh-Denmark/fmdk-zone.git';
}

#ffnord::dhcpd::static {
#  'fmdk': static_git => 'git://github.com/Freemesh-Denmark/ffgc-static.git';
#}

class {
  'ffnord::vpn::provider::hideio':
    openvpn_server => "nl.hide.io",
    openvpn_port   => 3478,
    openvpn_user   => "wayne",
    openvpn_password => "brucessecretpw",
}

#ffnord::icvpn::setup {
#  'gotham_city0':
#    icvpn_as => 65035,
#    icvpn_ipv4_address => "10.112.0.1",
#   icvpn_ipv6_address => "fec0::a:cf:0:35",
#   icvpn_exclude_peerings     => [gotham],
#   tinc_keyfile       => "/root/tinc_rsa_key.priv"
#}

#class {
#  'ffnord::monitor::munin':
#    host => '10.35.31.1'
#}

#class {
#  'ffnord::monitor::nrpe':
#    allowed_hosts => '10.35.31.1'
#}

#class {
#  'ffnord::monitor::zabbix':
#    zabbixserver => "10.35.31.1";
#}

#class { 
#    'ffnord::alfred': master => true # there may be only one gateway with master => true!
#}

class { 'ffnord::etckeeper': }

# Useful packages
package {
    # make sure that apt-transport-https is installed before starting
  ['vim','dnsutils','realpath','screen','htop','tcpdump','mlocate','tig']:
    ensure => installed;
}
