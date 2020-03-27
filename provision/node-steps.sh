#!/bin/bash

while [ -z "$(ssh -o stricthostkeychecking=no 172.27.11.10 stat /root/.kube)" ]; do
    sleep 5
done

scp -r root@172.27.11.10:/var/cache/apt/archives /var/cache/apt/
bash /vagrant/provision/packages.sh
usermod -G docker -a vagrant
echo "KUBELET_EXTRA_ARGS='--node-ip=172.27.11.$1'" > /etc/default/kubelet

while [ -z "$(ssh 172.27.11.10 stat /root/.kube/config)" ]; do
    sleep 5
done

$(ssh 172.27.11.10 kubeadm token create --print-join-command)
