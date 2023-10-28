#!/bin/bash

set -exo pipefail

echo "
###################################
# BEGIN: post-install knot
###################################
"

export DEBIAN_FRONTEND=noninteractive

OS=$(. /etc/os-release; echo $NAME)
if [[ "${OS}" = "Ubuntu" ]] || { echo "Unsupported OS: ${OS}" ; exit 1 ; }

wget https://secure.nic.cz/files/knot-resolver/knot-resolver-release.deb
dpkg -i knot-resolver-release.deb
apt-get update
apt-get install -y knot-resolver

echo `hostname -I` `hostname` >> /etc/hosts
sed -i 's/^\(nameserver 127.0.0.53\)$/#\1\nnameserver 127.0.0.1/'
systemctl stop systemd-resolved
systemctl disable systemd-resolved

echo "
-- forward all cache misses to Amazon Route 53 Resolver
-- See: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-dns.html
policy.add(policy.all(policy.STUB({'fd00:ec2::253', '169.254.169.253'})))
-- When DNSSEC enabled on Route53, use below instead.
-- policy.add(policy.all(policy.FORWARD({'fd00:ec2::253', '169.254.169.253'})))
" >> /etc/knot-resolver/kresd.conf

systemctl enable --now kresd@1.service
systemctl enable --now kresd@2.service
systemctl enable --now kresd@3.service
systemctl enable --now kresd@4.service

echo "
###################################
# END: post-install knot
###################################
"
