FROM centos:7

MAINTAINER John Koelndorfer <jkoelndorfer@gmail.com>

# Additional software repositories.
RUN rpm --import 'http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7'      && \
    rpm --import 'https://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7'  && \
    rpm --import 'https://dl.iuscommunity.org/pub/ius/IUS-COMMUNITY-GPG-KEY' && \
    yum -y install centos-release-scl centos-release-scl-rh \
                   epel-release       'https://centos7.iuscommunity.org/ius-release.rpm'

# Enable yum installing documentation. We need this for man pages!
#
# I like man pages.
RUN sed -i -e '/^tsflags=/d' /etc/yum.conf

# Reinstall any already-installed software so that we get its documentation.
RUN yum -y reinstall '*'

# Install the absolute basics.
RUN yum -y install openssh openssh-clients openssh-server sudo supervisor

# Install all the nice user applications.
#
# TODO: Make the list of packages a build arg once Ansible 2.2 releases
RUN yum -y install git man-db man-pages python35u ruby tmux vim-enhanced weechat zsh && \
    yum clean all && \
    rm -rf /var/cache/yum/*

# Fix sshd settings.
RUN sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/'               /etc/ssh/sshd_config && \
    sed -i -e 's/^#GSSAPIAuthentication yes/GSSAPIAuthentication no/'     /etc/ssh/sshd_config && \
    sed -i -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i -e 's!^HostKey /etc/ssh!HostKey /etc/ssh/host_keys!'           /etc/ssh/sshd_config

# sshd host keys are generated at boot time if they don't already exist.
RUN mkdir /etc/ssh/host_keys

COPY build/wheel-passwordless-sudo /etc/sudoers.d/wheel-passwordless-sudo
COPY app/entrypoint.sh /app/entrypoint.sh
COPY app/supervisord.ini /etc/supervisord.d/supervisord.ini

EXPOSE 22

VOLUME ["/home", "/etc/ssh/host_keys"]

CMD ["/app/entrypoint.sh"]
