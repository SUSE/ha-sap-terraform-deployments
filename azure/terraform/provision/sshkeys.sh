#!/bin/bash

mv /tmp/node0_id_rsa /tmp/$(hostname -s | sed -r 's/[0-9]+$//')0_id_rsa
mv /tmp/node0_id_rsa.pub /tmp/$(hostname -s | sed -r 's/[0-9]+$//')0_id_rsa.pub
mv /tmp/node1_id_rsa /tmp/$(hostname -s | sed -r 's/[0-9]+$//')1_id_rsa
mv /tmp/node1_id_rsa.pub /tmp/$(hostname -s | sed -r 's/[0-9]+$//')1_id_rsa.pub

# We move the ssh keys to the proper location.
mkdir -p $HOME/.ssh
mv /tmp/"$(hostname -s)"_id_rsa $HOME/.ssh/id_rsa
mv /tmp/"$(hostname -s)"_id_rsa.pub $HOME/.ssh/id_rsa.pub
chmod 600 $HOME/.ssh/id_rsa

for i in $(ls /tmp/*.pub)
do 
  (cat "${i}"; echo) >>  $HOME/.ssh/authorized_keys
done
