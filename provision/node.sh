#!/bin/bash

while true; do
    ssh -o stricthostkeychecking=no 172.27.11.10 stat /root/.kube/config
    if [ "$?" -eq '0' ]; then
        $(ssh 172.27.11.10 kubeadm token create --print-join-command)
        break
    fi
    sleep 5
done

usermod -G docker -a vagrant
echo "KUBELET_EXTRA_ARGS='--node-ip=172.27.11.$1'" > /etc/default/kubelet

while true; do
    ssh -o stricthostkeychecking=no 172.27.11.10 stat /root/.kube/config
    if [ "$?" -eq '0' ]; then
        $(ssh 172.27.11.10 kubeadm token create --print-join-command)
        break
    fi
    sleep 5
done
