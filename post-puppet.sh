#!/bin/bash
#https://github.com/ffnord/ffnord-puppet-gateway

VPN_NUMBER=0
DOMAIN="freemesh.dk"
TLD="fmdk"
IP6PREFIX=....

##NGINX if needed to serve the firmware for the auto-updater
#apt-get install -y nginx

#mkdir /opt/www
#sed s~"usr/share/nginx/www;"~"opt/www;"~g -i /etc/nginx/sites-enabled/default

#DNS Server
echo "dns-search gw$VPN_NUMBER.$DOMAIN" >>/etc/network/interfaces

rm /etc/resolv.conf
cat >> /etc/resolv.conf <<-EOF
	domain $TLD
	search $TLD
	nameserver 127.0.0.1
	nameserver 213.133.98.98
	nameserver 213.133.99.99
	nameserver 213.133.100.100
	nameserver 8.8.8.8
EOF

mv /etc/radvd.conf /etc/radvd.conf.bak
cat >> /etc/radvd.conf << EOF
# managed for interface br-$TLD
interface br-$TLD
{
 AdvSendAdvert on;
 AdvDefaultLifetime 0; # Here
 IgnoreIfMissing on;
 MaxRtrAdvInterval 200;

 prefix $IP6PREFIX:0000:0000:0000:0000/64
 {
   AdvPreferredLifetime 14400; # Here
   AdvValidLifetime 86400; # Here
 };

 RDNSS $IP6PREFIX::ff0$VPN_NUMBER
 {
 };

 route fc00::/7  # this block
 {
   AdvRouteLifetime 1200;
 };
};
EOF
cp /etc/radvd.conf /etc/radvd.conf.d/interface-br-$TLD.conf

# set conntrack_max higher so more connections are possible:
/sbin/sysctl -w net.netfilter.nf_conntrack_max=1048576 && echo net.ipv4.netfilter.ip_conntrack_max = 1048576 >> /etc/sysctl.conf

# check if everything is running:
service fastd restart
service isc-dhcp-server restart
check-services
