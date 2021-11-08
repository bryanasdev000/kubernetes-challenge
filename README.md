# Kubernetes - Challenge

Você consegue consertar este cluster e completar algumas pequenas tarefas propostas?

O objetivo deste repositório é criar um laboratório semelhante ao encontrado na prova da certificação CKA, fornecer alguns problemas e um validador capaz de dizer se a tarefa foi concluída com sucesso ou não.

Ao total, existem 8 tarefas a serem completas - porém somente 5 delas possuem validador - estou trabalhando nisso.

## Como Funciona?

Tudo o que precisa é do VirtualBox e do Vagrant, clone o repositório, espere a instalação e então acesse qualquer máquina que desejar:

```bash
git clone https://github.com/hector-vido/kubernetes-challenge.git
cd kubernetes-challenge
vagrant up
vagrant status
vagrant ssh master
```

A máquina responsável por validar os passos e fornecer as tarefas é a **master**, uma vez lá dentro execute:

  k8s-tasks

Para visualizar as tarefas, e depois de feitas, execute:

  k8s-check

Para validá-las.

## Infraestrutura

A infraestrutura é composta de 1 master e 2 nodes:

| Máquina             | Endereço      | Papel         |
|---------------------|---------------|---------------|
| master.example.com  | 172.27.11.10  | master        |
| node1.example.com   | 172.27.11.20  | node          |
| node2.example.com   | 172.27.11.30  | node          |

## Processo de Provisionamento

Os scripts de provisionamento das máquinas parecem relativamente complexos pois o laboratório foi pensado para utilizar o mínimo possível de conexão com a internet.

Por conta disso a máquina **master** baixa todos os pacotes necessários enquanto que os **nodes** através de um loop conseguem saber o momento exato para puxar os pacotes para sí e iniciar a instalação dos pacotes além de ingressarem no cluster.

A ordem de inicialização é o contrário do óbvio, a **master** é a última máquina a ser criada.

## Tarefas

Algumas tarefas são mais difíceis do que outras - principalmente a primeira que exige conhecimentos mais profundos da infraestrutura por trás do Kubernetes, depois dela as tarefas são relativamente simples e começam a ficar mais difíceis conforme segue.

- Corrigir o problema de comunicação entre as máquinas:  
  - master...172.27.11.10  
  - node1....172.27.11.20  
  - node2....172.27.11.30  
  - **Obs**: Não utilizar kubeadm, não resetar o cluster. SSH através do usuário "root" está liberado entre as máquinas citadas. O namespace deverá ser sempre o "default" a não ser que especificado.
- Provisionar um pod chamado "apache" com a imagem "httpd:alpine"  
- Criar um deployment chamado "cgi" com a imagem "hectorvido/sh-cgi" e um service.  
  - O deployment deverá possuir 4 réplicas.  
  - Criar um serviço chamado "cgi" para o deploy "cgi"  
  - O serviço responderá internamente através da porta 9090.  
- Criar um deploy chamado "nginx" baseado em nginx:alpine  
  - Atualizar o deployment para a imagem "nginx:perl"  
  - Faça rollback para a versão anterior.  
- Criar um pod de "memcached:alpine" para cada "worker" do cluster.  
  - Caso um novo "node" seja adicionado ao cluster, uma réplica deste pod precisa sder automaticamente provisionada dentro do novo nó.  
- Criar um pod com a imagem "hectorvido/apache-auth" chamado "auth"  
  - Criar um Secret chamado "httpd-auth" baseado no arquivo files/auth.ini  
  - Criar duas variáveis de ambiente no pod: HTPASSWD_USER e HTPASSWD_PASS com os respectivos valores de "httpd-auth"  
  - Criar um ConfigMap chamado "httpd-conf" com o conteúdo de files/httpd.conf  
  - Montá-lo dentro do pod em /etc/apache2/httpd.conf utilizando "subpath"  
  - A página deve ser exibida somente com a execução do seguinte comando: `curl -u developer:4linux 10.244.10.1`, do contrário uma mensagem de não autorização deverá aparecer.  
  - **Obs:** Nenhuma configuração extra é necessária, o Secret e o ConfigMap cuidam de todo processo de configuração.
- Criar um pod chamado "tools"
  - O pod deverá utilizar a imagem "busybox"
  - O pod deverá ser estático
  - O pod deverá estar presente somente no "node1"
- Criar um statefulSet chamado "couchdb" com a imagem "couchdb".
  - O "headless service" deverá se chamar "couchdb".
	- Utilizar o namespace "database" - já está criado.
	- O pod poderá apenas ir para a máquina "node2".
	- O usuário de conexão deve ser "developer" e senha "4linux".
	- O serviço deve se chamar "couchdb" e escutar na porta 5984.
	- Criar o diretório "/srv/couchdb" na máquina "node2".
	- Criar um volume persistente que utilize este diretório.
	- Persistir os dados do couchdb no volume criado acima.
	- O diretório utilizado pelo couchdb é "/opt/couchdb/data".

## TODO

- Adicionar task de backup e restore do ETCD (com etcdctl/depreciado e etcdutl/novo)
- Adicionar task de NetworkPolicy
- Adicionar task de Taints/Affinity
- Adicionar task de Scheduler manual
- Adicionar task de upgrade do cluster
- Adicionar task de renovação de certificado
- Adicionar task de output customizada (jsonpath + sortby)
- Fix CoreDNS forwarding no Vagrant (de /etc/hosts para 8.8.8.8 ou 1.1.1.1 para nomes externos)
- Adicionar tasks de informações do cluster
