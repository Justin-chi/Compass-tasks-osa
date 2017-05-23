#!/usr/bin/env bash
# Copyright 2015, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This script was created to rapidly interate through a repo_package file
# that contains git sources and set the various repositories inside to
# the head of given branch via the SHA. This makes it possible to update
# all of the services that we support in an "automated" fashion.

OS_BRANCH=${OS_BRANCH:-"master"}
OSA_BRANCH=${OSA_BRANCH:-"$OS_BRANCH"}
SERVICE_FILE=${SERVICE_FILE:-"./openstack_services.yml"}
OPENSTACK_SERVICE_LIST=${OPENSTACK_SERVICE_LIST:-"$(grep 'git_repo\:' ${SERVICE_FILE} | awk -F '/' '{ print $NF }' | egrep -v 'requirements|-' | tr '\n' ' ')"}
PRE_RELEASE=${PRE_RELEASE:-"false"}

IFS=$'\n'

if echo "$@" | grep -e '-h' -e '--help';then
    echo "
Options:
  -b|--openstack-branch (name of OpenStack branch, eg: stable/newton)
  -o|--osa-branch       (name of the OSA branch, eg: stable/newton)
  -s|--service-file     (path to service file to parse)
"
exit 0
fi

# Provide some CLI options
while [[ $# > 1 ]]; do
key="$1"
case $key in
    -b|--openstack-branch)
    OS_BRANCH="$2"
    shift
    ;;
    -o|--osa-branch)
    OSA_BRANCH="$2"
    shift
    ;;
    -s|--service-file)
    SERVICE_FILE="$2"
    shift
    ;;
    *)
    ;;
esac
shift
done

# Iterate through the service file
for repo in $(grep 'git_repo\:' ${SERVICE_FILE}); do

  echo -e "\nInspecting ${repo}..."

  # Set the repo name
  repo_name=$(echo "${repo}" | sed 's/_git_repo\:.*//g')

  # Set the repo address
  repo_address=$(echo ${repo} | awk '{print $2}')

  # Get the branch data
  branch_data=$(git ls-remote ${repo_address} | grep "${OS_BRANCH}$")

  # If there is branch data continue
  if [ ! -z "${branch_data}" ];then

    # Set the branch sha for the head of the branch
    branch_sha=$(echo "${branch_data}" | awk '{print $1}')

    # Set the branch entry
    branch_entry="${branch_sha} # HEAD of \"$OS_BRANCH\" as of $(date +%d.%m.%Y)"

    # Write the branch entry into the repo_packages file
    sed -i.bak "s|${repo_name}_git_install_branch:.*|${repo_name}_git_install_branch: $branch_entry|" ${SERVICE_FILE}

    # If the repo is in the specified list, then action the additional updates
    if [[ "${OPENSTACK_SERVICE_LIST}" =~ "${repo_name}" ]]; then
      os_repo_tmp_path="./openstack/${repo_name}"
      osa_repo_tmp_path="/osa/${repo_name}"

      # Ensure that the temp path doesn't exist
      rm -rf ${os_repo_tmp_path} ${osa_repo_tmp_path}

      # Do a shallow clone of the OpenStack repo to work with
      if git clone --branch ${OS_BRANCH} --no-checkout --single-branch ${repo_address} ${os_repo_tmp_path}; then
        pushd ${os_repo_tmp_path} > /dev/null
          git checkout ${branch_sha}
        popd > /dev/null
      fi

      # Clean up the temporary files
      # rm -rf ${os_repo_tmp_path} ${osa_repo_tmp_path}
    fi
  fi

  echo -e "Processed $repo_name @ $branch_entry\n"

done

unset IFS

