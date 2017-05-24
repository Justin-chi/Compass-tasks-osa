FROM huangxiangyu/compass-tasks:v0.1
#FROM localbuild/compass-tasks

#RUN yum upgrade -y && \
RUN yum install https://rdoproject.org/repos/openstack-ocata/rdo-release-ocata.rpm -y && \
    yum install git ntp ntpdate openssh-server python-devel sudo '@Development Tools' -y

RUN git clone https://git.openstack.org/openstack/openstack-ansible /opt/openstack-ansible

RUN cd /opt/openstack-ansible && \
    git checkout -b ocata remotes/origin/stable/ocata

RUN /bin/cp -rf /opt/openstack-ansible/etc/openstack_deploy /etc/openstack_deploy

RUN cd /opt/openstack-ansible && \
    scripts/bootstrap-ansible.sh

RUN rm -f /usr/local/bin/ansible-playbook

RUN cd /opt/openstack-ansible/scripts/ && \
    python pw-token-gen.py --file /etc/openstack_deploy/user_secrets.yml

ADD cinder.yml /etc/openstack_deploy/env.d/cinder.yml

RUN cd /opt/openstack-ansible/playbooks/inventory/group_vars && \
    sed -i 's/#repo_build_git_cache/repo_build_git_cache/g' repo_all.yml

RUN mkdir -p /opt/git/openstack
ADD sources-branch-updater.sh /opt/git/sources-branch-updater.sh
ADD openstack_services.yml /opt/git/openstack_services.yml
ADD get_openstack_code.sh /opt/git/get_openstack_code.sh
RUN chmod +x /opt/git/*.sh
RUN /opt/git/get_openstack_code.sh

RUN yum clean all
