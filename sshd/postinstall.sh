#!/bin/bash

# AD integration causes pcluster to re-enable ssh password authentication.
# This post-install script reverse that action, to re-re-disable ssh password auth.

sed -ri 's/\s*PasswordAuthentication\s+yes$/PasswordAuthentication no/g' /etc/ssh/sshd_config
systemctl restart sshd
