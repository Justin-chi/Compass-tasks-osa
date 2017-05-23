#!/bin/bash

OSA_ROLES_FILE=ansible-role-requirements.yml
OSA_ROLES_URL=https://raw.githubusercontent.com/openstack/openstack-ansible/stable/ocata/${OSA_ROLES_FILE}

wget ${OSA_ROLES_URL}

python parser.py ${OSA_ROLES_FILE}


