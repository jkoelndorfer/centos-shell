FROM fedora:24

MAINTAINER John Koelndorfer <jkoelndorfer@gmail.com>

# Reinstall any already-installed software so that we get its documentation.
RUN dnf -y reinstall '*'

# Install the absolute basics.
RUN dnf -y install openssh openssh-clients openssh-server sudo supervisor

# Install all the nice user applications.
#
# TODO: Make the list of packages a build arg once Ansible 2.2 releases
RUN dnf -y install \
        ansible \
        bind-utils \
        git \
        hostname \
        man \
        man-pages \
        net-tools \
        nmap \
        nmap-ncat \
        procps-ng \
        ruby \
        tmux \
        vim-enhanced \
        weechat \
        zsh \
        && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

RUN pip3 install hangups

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

# This needs to be removed before login via ssh will be allowed.
RUN rm -f /var/run/nologin

EXPOSE 22

VOLUME ["/home", "/etc/ssh/host_keys"]

CMD ["/app/entrypoint.sh"]
