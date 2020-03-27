#!/bin/bash

bash /vagrant/provision/node-steps.sh $1 > /tmp/provision.log  2>&1 &
