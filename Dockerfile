FROM huangxiangyu/compass-tasks:v0.1
#FROM localbuild/compass-tasks

#install package
RUN yum install https://rdoproject.org/repos/openstack-ocata/rdo-release-ocata.rpm -y && \
    yum install git ntp ntpdate openssh-server python-devel sudo '@Development Tools' -y

#copy files
COPY cinder.yml /etc/openstack_deploy/env.d/cinder.yml
COPY *.sh openstack_services.yml /opt/git

#run scripts
RUN run.sh

#clean
RUN yum clean all
