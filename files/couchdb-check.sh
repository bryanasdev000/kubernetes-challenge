#!/bin/#!/usr/bin/env bash

function echo_warning {
	echo -e "\033[0;33m$1\033[0m"
}

while [ -z "$(kubectl get pod couchdb-0 -n database | grep Running)" ]; do
	echo_warning "Esperando pod inicializar..."
	sleep 2
done

while [ -z "$(kubectl exec -ti couchdb-0 -n database -- curl --connect-timeout 1 -X PUT -u developer:4linux couchdb:5984/check 2> /dev/null | grep ok)" ]; do
	echo_warning "Esperando aplicação..."
	sleep 2
done

for X in 'Amigo' 'O Portão' 'Cavalgada' 'Vivendo por Viver' 'Ternura' 'Nossa Canção', 'Ilegal, Imoral ou Engorda', 'Quando', 'Se Você Pensa'; do
	kubectl exec -ti couchdb-0 -n database -- curl -u developer:4linux -H 'Content-Type: application/json' -d "{\"selector\": {\"nome\": \"$X\"}}" couchdb:5984/robertocarlos/_find | grep "$X" > /dev/null
	if [ "$?" -eq 0 ]; then
		echo "Música \"$X\" encontrada!"
	else
		exit 1
	fi
done
