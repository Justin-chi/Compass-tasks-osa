#!/bin/bash

git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible
pushd /opt/openstack-ansible >/dev/null
    git checkout -b ocata remotes/origin/stable/ocata
popd > /dev/null

cp -rf /opt/openstack-ansible/etc/openstack_deploy /etc/openstack_deploy

pushd /opt/openstack-ansible >/dev/null
   scripts/bootstrap-ansible.sh
popd > /dev/null

rm -f /usr/local/bin/ansible-playbook

pushd /opt/openstack-ansible/scripts >/dev/null
    python pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml
popd > /dev/null

pushd /opt/openstack-ansible/playbooks/inventory/group_vars > /dev/null
    sed -i 's/#repo_build_git_cache/repo_build_git_cache/g' repo_all.yml
popd

mkdir -p /opt/git/openstack

pushd /opt/git > /dev/null
./sources-branch-updater.sh -o stable/ocata -b stable/ocata -s ./openstack_services.yml
find ./openstack/ -name ".git" | xargs rm -rf
popd

