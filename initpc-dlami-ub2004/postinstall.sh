#!/bin/bash

# Reuse initsmhp, but not these:
# - fix ssh, because pcluster has its own mechanics.
# - gen ssh keypair, because pcluster already does this.

[[ "$1" == "" ]] && NODE_TYPE=other || NODE_TYPE="$1"

set -exuo pipefail

# Don't let new lustre client module brings in new kernel.
echo "lustre-client-modules-aws hold" | sudo dpkg --set-selections

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
cp $BIN_DIR/initsmhp/vimrc /etc/skel/.vimrc

if [[ "${NODE_TYPE}" == "controller" ]]; then
    echo "[INFO] This is a Controller node."
    bash -x $BIN_DIR/initsmhp/fix-bash.sh ~ubuntu/.bashrc
    cp $BIN_DIR/initsmhp/vimrc ~ubuntu/.vimrc && chown ubuntu:ubuntu ~ubuntu/.vimrc
    bash -x $BIN_DIR/initsmhp/howto-miniconda.sh
fi

# Placeholder for terminfo. No actual terminfo is setup. Instead, ubuntu user
# must follow https://sw.kovidgoyal.net/kitty/kittens/ssh/ if needed.
/bin/bash -c '
if [[ ! -f ~/.terminfo/x/xterm-kitty ]]; then
    mkdir -p ~/.terminfo/x/
    ln -s ~ubuntu/.terminfo/x/xterm-kitty ~/.terminfo/x/
fi
'
