#!/bin/bash

./sources-branch-updater.sh -o stable/ocata -b stable/ocata -s ./openstack_services.yml
find ./openstack/ -name ".git" | xargs rm -rf

