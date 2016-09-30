#!/bin/bash

# Create our user.
useradd --no-user-group --create-home --uid "${USER_UID:-500}" \
        --groups wheel --shell "${USER_SHELL:-/bin/bash}" "$USER_NAME"

# Generate sshd host keys if they don't exist.
for key_type in rsa ecdsa ed25519; do
    key_path="/etc/ssh/host_keys/ssh_host_${key_type}_key"
    [[ -f "$key_path" ]] && continue
    ssh-keygen -C '' -N '' -t "$key_type" -f "$key_path"
done

exec /usr/bin/supervisord -n
