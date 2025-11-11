#!/bin/bash

#Generates public and private key for ssh share
ssh-keygen -q -t rsa -N '' <<< $'\ny' >/dev/null 2>&1

#copies public key for transfer in the MetaSploit folder
cp ~/.ssh/id_rsa.pub ./MetaSploit/id_rsa.pub

#copies private key for transfer in the Ubuntu folder
cp ~/.ssh/id_rsa ./Ubuntu/id_rsa
