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
  - Caso um novo "worker" seja adicionado ao cluster, uma réplica deste pod precisa automaticamente ser provisionado dentro do novo nó.  
- Criar um pod com a imagem "hectorvido/apache-auth" chamado "auth"  
  - Criar um Secret chamado "httpd-auth" baseado no arquivo files/auth.ini  
  - Criar duas variáveis de ambiente no pod: USER e PASS com os respectivos valores de "httpd-auth"  
  - Criar um ConfigMap chamado "httpd-conf" com o conteúdo de files/httpd.conf  
  - Montá-lo dentro do pod em /usr/local/apache2/conf utilizando "subpath"  
  - A página deve ser exibida somente com a execução do seguinte comando: `curl -u developer:4linux 10.244.10.1`, do contrário uma mensagem de não autorização deverá aparecer.  
  - **Obs:** Nenhuma configuração extra é necessária, o Secret e o ConfigMap cuidam de todo processo de configuração.
- Criar um deploy com a imagem "couchdb" chamado "couchdb".  
  - Utilizar o namespace "database" - já está criado  
  - A única réplica poderá apenas ir para a máquina "node2".  
  - Criar o diretório "/srv/couchdb" na máquina "node2".  
  - Criar um volume persistente que utilize este diretório.  
  - Persistir os dados do couchdb no volume criado acima.  
  - O diretório utilizado pelo couchdb é "/opt/couchdb/data".  
  - Criar um serviço escutando na porta 5984  
- Criar um pod chamado "busybox" na máquina "master"  
  - O pod deverá ser estático  
