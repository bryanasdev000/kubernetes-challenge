#!/bin/bash

bash /vagrant/provision/packages.sh

mkdir -p ~/.kube
mkdir -p /home/vagrant/.kube

echo "KUBELET_EXTRA_ARGS='--node-ip=172.27.11.$1'" > /etc/default/kubelet
kubeadm init --apiserver-advertise-address=172.27.11.10 --pod-network-cidr=10.244.0.0/16
cp /etc/kubernetes/admin.conf ~/.kube/config
cp /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown -R vagrant: /home/vagrant/.kube
curl -s https://docs.projectcalico.org/manifests/calico.yaml > /root/calico.yml
sed -i 's?192.168.0.0/16?10.244.0.0/16?g' /root/calico.yml
kubectl apply -f /root/calico.yml

cp /vagrant/files/tasks.sh /usr/local/bin/k8s-tasks
cp /vagrant/files/check.sh /usr/local/bin/k8s-check
chmod +x /usr/local/bin/k8s-*

usermod -G docker -a vagrant
bash /vagrant/provision/messup.sh &
