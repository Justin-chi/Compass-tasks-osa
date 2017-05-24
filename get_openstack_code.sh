#!/bin/bash

/opt/git/sources-branch-updater.sh -o stable/ocata -b stable/ocata -s /opt/git/openstack_services.yml
find /opt/git/openstack/ -name ".git" | xargs rm -rf

