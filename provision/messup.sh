#!/bin/bash

# ATENÇÃO: A execução deste script cria parte do cenário de testes.
# Se deseja aprender a resolver problemas do cluster não leia este arquivo
# antes de tentar resolver o problema de comunicação entre os nós.

while [ "$(kubectl get nodes --no-headers | wc -l)" -lt 3 ]; do
  sleep 1
done

ssh -o stricthostkeychecking=no root@172.27.11.20 "systemctl stop kubelet && systemctl daemon-reload && rm -rf /lib/systemd/system/kubelet.service"
ssh -o stricthostkeychecking=no root@172.27.11.30 "sed -i 's/ systemd/ cgroupfs/' /var/lib/kubelet/config.yaml && systemctl restart kubelet"

sed -i 's,/etc/kubernetes/manifests,/etc/kubernete/manifest,' /var/lib/kubelet/config.yaml
systemctl restart kubelet
chmod -x $(which kubectl)
