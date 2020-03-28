#!/bin/#!/usr/bin/env bash

kubectl exec -ti couchdb-0 -n database -- curl -X DELETE -u developer:4linux couchdb:5984/check > /dev/null
kubectl exec -ti couchdb-0 -n database -- curl -X DELETE -u developer:4linux couchdb:5984/robertocarlos > /dev/null

kubectl exec -ti couchdb-0 -n database -- curl -X PUT -u developer:4linux couchdb:5984/robertocarlos > /dev/null

for X in 'Amigo' 'O Portão' 'Cavalgada' 'Vivendo por Viver' 'Ternura' 'Nossa Canção', 'Ilegal, Imoral ou Engorda', 'Quando', 'Se Você Pensa'; do
	kubectl exec -ti couchdb-0 -n database -- curl -u developer:4linux -H 'Content-Type: application/json' -d "{\"nome\": \"$X\", \"seed\": \"$RANDOM\"}" couchdb:5984/robertocarlos > /dev/null
	echo "Música \"$X\" cadastrada!"
done
