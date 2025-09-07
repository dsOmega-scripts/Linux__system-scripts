#!/usr/bin/env bash

echo "Downgrading kernel and related packages..."

if [[ ! -x "$(command -v downgrade)" ]]; then
    echo "downgrade util is not installed"
    exit 1
fi

sudo downgrade \
    linux linux-headers \
    nvidia-dkms nvidia-settings nvidia-utils # Nvidia is connected to linux version, they should be downgraded in sync.

# FIX: For some reason Ctrl+C is considered 0 in downgrade.
# QUESTION: Not sure if it will take only last status or a whole command into account.
haveDowngradedPackages=$?

if [[ $downgradePackagesStatus -ne 0 ]]; then 
    exit downgradePackagesStatus
fi

function yes_or_no() {
    while true; do
        read -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}

if yes_or_no "Ready to reinstall zfs?"; then
    echo "Reinstalling zfs..."

    # Most likely it's enough to rebuild by dkms, I've seen this command in logs:
    # dkms install --no-depmod zfs/2.3.4.r0.g34f96a15c7 -k 6.15.7-arch1-1
    # But I'm not sure where `zfs/2.3.4...` comes from.
    yay -R zfs-dkms-staging-git && yay zfs-dkms-staging-git
fi
