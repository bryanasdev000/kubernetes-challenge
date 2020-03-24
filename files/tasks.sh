#!/bin/bash

cat <<EOF
##########################
#       Kubernetes       #
##########################

1 - Corrigir o problema de comunicação entre as máquinas:
		1.1 - master...172.27.11.10
		1.2 - node1....172.27.11.20
		1.3 - node2....172.27.11.30
	Obs: Não utilizar kubeadm, não resetar o cluster.
  SSH através do usuário "root" está liberado entre as máquinas citadas.
	O namespace deverá ser sempre o "default" a não ser que especificado.

2 - Provisionar um pod chamado "apache" com a imagem "httpd:alpine"

3 - Criar um deployment chamado "cgi" com a imagem "hectorvido/sh-cgi" e um service.
	3.1 - O deployment deverá possuir 4 réplicas.
	3.2 - Criar um serviço chamado "cgi" para o deploy "cgi"
	3.3 - O serviço responderá internamente através da porta 9090.

4 - Criar um deploy chamado "nginx:alpine" baseado em nginx:alpine
	4.1 - Atualizar o deployment para a imagem "nginx:perl"
	4.2 - Faça rollback para a versão anterior.

5 - Criar um pod de "memcached:alpine" para cada "worker" do cluster.
	5.1 - Caso um novo "worker" seja adicionado ao cluster, uma réplica
	deste pod precisa automaticamente ser provisionado dentro do novo nó.

6 - Criar um pod com a imagem "hectorvido/apache-auth" chamado "auth"
  6.1 - Criar um Secret chamado "httpd-auth" baseado no arquivo files/auth.ini
  6.2 - Criar duas variáveis de ambiente no pod: USER e PASS com os respectivos 
        valores de "httpd-auth"
  6.4 - Criar um ConfigMap chamado "httpd-conf" com o conteúdo de files/httpd.conf
  6.5 - Montá-lo dentro do pod em /usr/local/apache2/conf utilizando "subpath"
  6.6 - A página deve ser exibida somente com a execução do seguinte comando:
        curl -u developer:4linux 10.244.10.1
        Do contrário uma mensagem de não autorização deverá aparecer.
  Obs: Nenhuma configuração extra é necessária, o Secret e o ConfigMap cuidam
  de todo processo de configuração.

7 - Criar um deploy com a imagem "couchdb" chamado "couchdb".
  7.1 - Utilizar o namespace "database" - já está criado
  7.2 - A única réplica poderá apenas ir para a máquina "node2".
  7.3 - Criar o diretório "/srv/couchdb" na máquina "node2".
  7.4 - Criar um volume persistente que utilize este diretório.
  7.5 - Persistir os dados do couchdb no volume criado acima.
  7.6 - O diretório utilizado pelo couchdb é "/opt/couchdb/data".
  7.7 - Criar um serviço escutando na porta 5984

8 - Criar um pod chamado "busybox" na máquina "master"
  8.1 - O pod deverá ser estático
EOF
