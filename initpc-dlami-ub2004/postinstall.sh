#!/bin/bash

# Reuse initsmhp, but not these:
# - fix ssh, because pcluster has its own mechanics.
# - gen ssh keypair, because pcluster already does this.

[[ "$1" == "" ]] && NODE_TYPE=other || NODE_TYPE="$1"

set -exuo pipefail

cd /opt
git clone --single-branch -b main --depth 1 https://github.com/aws-samples/playground-persistent-cluster
mkdir -p /var/log/initsmhp
( cd playground-persistent-cluster && echo playground-persistent-cluster $(git rev-parse --short HEAD) )

BIN_DIR=/opt/playground-persistent-cluster/src/LifecycleScripts/base-config
chmod ugo+x $BIN_DIR/initsmhp/*.sh
declare -a PKGS_SCRIPTS=(
    install-pkgs.sh
    install-delta.sh
    install-duf.sh
    install-s5cmd.sh
    install-tmux.sh
    install-mount-s3.sh
)

for i in "${PKGS_SCRIPTS[@]}"; do
    bash -x $BIN_DIR/initsmhp/$i &> /var/log/initsmhp/$i.txt \
        && echo "SUCCESS: $i" >> /var/log/initsmhp/initsmhp.txt \
        || echo "FAIL: $i" >> /var/log/initsmhp/initsmhp.txt
done

bash -x $BIN_DIR/initsmhp/fix-profile.sh
bash -x $BIN_DIR/initsmhp/adjust-git.sh
bash -x $BIN_DIR/initsmhp/fix-bash.sh /etc/skel/.bashrc

if [[ "${NODE_TYPE}" == "controller" ]]; then
    echo "[INFO] This is a Controller node."
    bash -x $BIN_DIR/initsmhp/fix-bash.sh ~ubuntu/.bashrc
    bash -x $BIN_DIR/initsmhp/howto-miniconda.sh
fi
