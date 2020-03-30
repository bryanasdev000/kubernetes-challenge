#!/bin/bash

fails=('Ops...' 'Hum...' 'Eita...' 'Olha...' 'Veja bem...')
successes=('Parabéns!' 'Muito bom!' 'Isso!' 'Show!' 'Ae!')

function echo_fail {
	echo -e "\033[0;31m${fails[$(($RANDOM % 5))]} $1\033[0m"
	exit 1
}

function echo_warning {
	echo -e "\033[0;33m$1\033[0m"
}

function echo_success {
	echo -e "\033[0;32m${successes[$(($RANDOM % 5))]} $1\033[0m"
}

echo 'Task 1 - Verificando cluster...'
test ! -x /usr/bin/kubectl &&  echo_fail 'não conseguimos executar o comando kubectl.'
test "3" -ne "$(kubectl get nodes --no-headers | grep -wi ready | wc -l)" &&  echo_fail 'nem todos os três estão respondendo.'
echo_success 'Os três nodes estão respondendo!\n'

echo 'Task 2 - Pod chamado apache...'
kubectl -n default describe pod apache > /tmp/task2 2> /dev/null
test -z "$(cat /tmp/task2)" && echo_fail 'não conseguimos encontrar um pod chamado "apache".'
grep -E 'State: *Running' /tmp/task2 > /dev/null
test "0" -ne "$?" && echo_fail 'o pod parece não estar rodando.'
grep -E 'Image:.* httpd:alpine' /tmp/task2 > /dev/null
test "0" -ne "$?" && echo_fail 'a imagem do pod não é httpd:alpine.'
echo_success 'O pod está configurado corretamente!\n'

echo 'Task 3 - Deploy e serviço chamado cgi...'
kubectl -n default describe deploy cgi > /tmp/task3-1 2> /dev/null
test -z "$(cat /tmp/task3-1)" && echo_fail 'não conseguimos encontrar um deploy chamado "cgi".'
grep -Ew 'Replicas:.*4 available' /tmp/task3-1 > /dev/null
test "0" -ne "$?" && echo_fail 'parece que não há 4 replicas funcionando.'
grep -E 'Image: *hectorvido/sh-cgi$' /tmp/task3-1 > /dev/null
test "0" -ne "$?" && echo_fail 'a imagem utilizada não é hectorvido/sh-cgi.'
kubectl -n default describe svc cgi > /tmp/task3-2 2> /dev/null
test -z "$(cat /tmp/task3-2)" && echo_fail 'não conseguimos encontrar um serviço chamado "cgi".'
grep -E 'Port:.*9090/TCP' /tmp/task3-2 > /dev/null
test "0" -ne "$?" && echo_fail 'a porta 9090 parece não estar aberta no serviço "cgi".'
curl --connect-timeout 2 -s $(grep 'IP:' /tmp/task3-2 | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}'):9090 > /dev/null
test "0" -ne "$?" && echo_fail 'a conexão com a aplicação na porta 9090 parece estar com problemas.'
echo_success 'O pod e o serviço estão configurados corretamente!\n'

echo 'Task 4 - Deploy chamado nginx...'
kubectl -n default describe deploy nginx > /tmp/task4-1 2> /dev/null
test -z "$(cat /tmp/task4-1)" && echo_fail 'não conseguimos encontrar um deploy chamado "nginx".'
kubectl get rs | grep nginx- | cut -d' ' -f1 | xargs kubectl describe rs | grep -E 'Image: *nginx:alpine$' > /dev/null
test "0" -ne "$?" && echo_fail ' versão com nginx:alpine não encontrada.'
kubectl get rs | grep nginx- | cut -d' ' -f1 | xargs kubectl describe rs | grep -E 'Image: *nginx:perl$' > /dev/null
test "0" -ne "$?" && echo_fail ' versão com nginx:perl não encontrada.'
grep -E 'Image: *nginx:alpine$' /tmp/task4-1 > /dev/null
test "0" -ne "$?" && echo_fail 'a imagem utilizada não é nginx:alpine.'
echo_success 'O deploy foi atualizado e recuperado corretamente!\n'

echo 'Task 5 - Pods em todos os workers...'
kubectl -n default describe ds > /tmp/task5 2> /dev/null
test -z "$(cat /tmp/task5)" && echo_fail 'não encontramos o objeto ideal para os pods.'
grep -E 'Image: *memcached:alpine$' /tmp/task5 > /dev/null
test "0" -ne "$?" && echo_fail 'não encontramos os pods baseados em "memcached:alpine".'
kubectl describe ds -n default | grep -E 'Image: *memcached:alpine$' > /dev/null
echo_success 'O replicaset foi criado corretamente!\n'

echo 'Task 6 - Apache com autenticação...'
kubectl -n default describe secret httpd-auth > /tmp/task6-1 2> /dev/null
test -z "$(cat /tmp/task6-1)" && echo_fail 'não encontramos o secret "httpd-auth".'
test "$(grep -E '^HTPASSWD_USER|^HTPASSWD_PASS' /tmp/task6-1 | wc -l)" -ne 2 && echo_fail 'O secret não possui as chaves USER e PASS.'
kubectl -n default describe cm httpd-conf > /tmp/task6-2 2> /dev/null
test -z "$(cat /tmp/task6-2)" && echo_fail 'não encontramos o configMap "httpd-conf".'
kubectl describe pod auth -n default > /tmp/task6-3 2> /dev/null
ENV_FROM="$(grep -oEz 'Environment Variables from.*httpd-auth ' /tmp/task6-3)"
ENV_REF="$(grep -E 'HTPASSWD_USER:|HTPASSWD_PASS:' /tmp/task6-3 | wc -l)"
if [ -z "$ENV_FROM" ] && [ "$ENV_REF" -ne 2 ]; then echo_fail 'não encontramos as variáveis dentro do pod "auth".'; fi
grep -E '/etc/apache2/httpd.conf.*path="httpd.conf"' /tmp/task6-3 > /dev/null
test "0" -ne "$?" && echo_fail 'não encontramos o configMap "httpd-conf" dentro do pod "auth" montado com subPath.'
POD_IP=$(grep -Eo '^IP: *([0-9]{1,3}\.){3}[0-9]{1,3}$' /tmp/task6-3 | sed 's/IP: *//')
HTTP_STATUS="$(curl -u developer:4linux -s -o /dev/null -w '%{http_code}' $POD_IP)"
test "$HTTP_STATUS" -ne "200" && echo_fail "não conseguimos acessar o pod no endereço $POD_IP."
echo_success 'O pod "auth" foi criado corretamente!\n'

echo 'Task 7 - Pod estático'
kubectl -n default describe pod tools-node1 > /tmp/task7 2> /dev/null
test -z "$(cat /tmp/task7)" && echo_fail 'não conseguimos encontrar o pod estático "tools-node1".'
ssh -o stricthostkeychecking=no 172.27.11.20 "grep -roEz 'metadata:\s*name: *tools.*image: busybox' /etc/kubernetes/manifests > /dev/null 2>&1"
test "0" -ne "$?" && echo_fail 'não encontramos a definição correta do pod no "node1".'
grep -E 'State: *Running' /tmp/task7 > /dev/null
test "0" -ne "$?" && echo_fail 'o pod parece não estar rodando.'
kubectl get pod tools-node1 -o wide -n default 2> /dev/null | grep node1 > /dev/null 2>&1
test "0" -ne "$?" && echo_fail 'O pod não está no "node1".'
echo_success 'O pod estático foi criado corretamente!\n'

echo 'Task 8 - Boas práticas para persistência...'
kubectl -n database describe statefulset couchdb > /tmp/task8-1 2> /dev/null
test -z "$(cat /tmp/task8-1)" && echo_fail 'não encontramos o statefulset "couchdb".'
kubectl get svc couchdb -n database > /dev/null 2>&1
test "0" -ne "$?" && echo_fail 'não encontramos o serviço "couchdb".'
grep -Ew 'Replicas:  1 desired | 1 total' /tmp/task8-1 > /dev/null
test "0" -ne "$?" && echo_fail 'parece que o pod não está funcionando.'
kubectl get pods -o wide -n database | grep couchdb | grep node2 > /dev/null 2>&1
test "0" -ne "$?" && echo_fail 'O pod não está no "node2".'
ssh -o stricthostkeychecking=no 172.27.11.30 stat /srv/couchdb > /dev/null 2>&1
test "0" -ne "$?" && echo_fail 'não encontramos o diretório "/srv/couchdb" no "node2".'
kubectl get pv --no-headers | cut -d' ' -f1 | xargs -n1 kubectl describe pv | grep -zEo 'HostPath.*/srv/couchdb' > /dev/null
test "0" -ne "$?" && echo_fail 'nenhum volume do tipo "HostPath" foi encontrado utilizando "/srv/couchdb".'
kubectl -n database describe statefulset couchdb > /tmp/task8-2
grep -zoE 'Mounts:.*/opt/couchdb/data.*Volume Claims:.*Name:' /tmp/task8-2 > /dev/null
test "0" -ne "$?" && echo_fail 'O pode não está utilizando um PVC apontando para "/srv/couchdb".'
echo_warning 'Limpando e importando músicas do Roberto Carlos para o couchdb...'
bash /vagrant/files/couchdb-import.sh
echo_warning 'Destruindo pod para testar persistência...'
kubectl delete pod couchdb-0 -n database
bash /vagrant/files/couchdb-check.sh
test "0" -ne "$?" && echo_fail 'Nem todos os dados foram encontrados, o volume está correto?'
echo_success 'O statefulset funcionou, todas as músicas do Roberto Carlos persistiram!\n'
