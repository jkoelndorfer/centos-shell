FROM fedora:24

MAINTAINER John Koelndorfer <jkoelndorfer@gmail.com>

# Reinstall any already-installed software so that we get its documentation.
RUN dnf -y reinstall '*'

# Install the absolute basics.
RUN dnf -y install openssh openssh-clients openssh-server sudo supervisor

# Install all the nice user applications.
#
# TODO: Make the list of packages a build arg once Ansible 2.2 releases
RUN dnf -y install git man man-pages python ruby tmux vim-enhanced weechat zsh    \
                   hostname                                                    && \
    dnf clean all && \
    rm -rf /var/cache/dnf/*

# Fix sshd settings.
#
# FIXME: We're setting the port in our Dockerfile here to work around a bug where Docker
# does not correctly publish ports when the exposed port and published port are different.
RUN sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/'               /etc/ssh/sshd_config && \
    sed -i -e 's/^#GSSAPIAuthentication yes/GSSAPIAuthentication no/'     /etc/ssh/sshd_config && \
    sed -i -e 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i -e 's/^#Port 22/Port 2225/'                                    /etc/ssh/sshd_config && \
    sed -i -e 's!^HostKey /etc/ssh!HostKey /etc/ssh/host_keys!'           /etc/ssh/sshd_config

# sshd host keys are generated at boot time if they don't already exist.
RUN mkdir /etc/ssh/host_keys

COPY build/wheel-passwordless-sudo /etc/sudoers.d/wheel-passwordless-sudo
COPY app/entrypoint.sh /app/entrypoint.sh
COPY app/supervisord.ini /etc/supervisord.d/supervisord.ini

# This needs to be removed before login via ssh will be allowed.
RUN rm -f /var/run/nologin

EXPOSE 2225

VOLUME ["/home", "/etc/ssh/host_keys"]

CMD ["/app/entrypoint.sh"]