#!/bin/bash

mkdir -p /root/.ssh
cp /vagrant/files/id_rsa* /root/.ssh
chmod 400 /root/.ssh/id_rsa*
cp /vagrant/files/id_rsa.pub /root/.ssh/authorized_keys

HOSTS=$(head -n7 /etc/hosts)
echo -e "$HOSTS" > /etc/hosts
echo '172.27.11.10 master.k8s.com' >> /etc/hosts
echo '172.27.11.20 node1.k8s.com' >> /etc/hosts
echo '172.27.11.30 node2.k8s.com' >> /etc/hosts
echo '172.27.11.40 storage.k8s.com' >> /etc/hosts

if [ "$HOSTNAME" == "storage" ]; then
	exit
fi

update-alternatives --set iptables /usr/sbin/iptables-legacy
update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
update-alternatives --set arptables /usr/sbin/arptables-legacy
update-alternatives --set ebtables /usr/sbin/ebtables-legacy

sed -Ei 's/(.*swap.*)/#\1/g' /etc/fstab
swapoff -a
