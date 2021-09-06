#!/bin/bash
# drivers Wi-Fi
# drivers souris
# drivers Nouveau Nvidia

# ensure that it is run as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

if [[ $1 -eq "upgrade" ]]; then
   dnf upgrade -y
fi

# RTL8821CE Wi-Fi issue
PCI_NAME="RTL8821CE"
lspci | grep $PCI_NAME &> /dev/null
if [[ $? == 0 ]]; then
    echo $PCI_NAME " adapter found, installing drivers ..."
    echo "Updating Kernel ..."
    dnf install -y kernel "kernel-*"
    dnf upgrade -y kernel "kernel-*"
    dnf install -y dkms
    git clone https://github.com/tomaspinho/rtl8821ce.git
    cd rtl8821ce
    ./dkms-install.sh
    if [ $? != 0 ]; then
        echo "Script failed, you might need to reboot and start it again"
    else
        echo $PCI_NAME " drivers installed in rtl8821ce directory, you are free to delete it."
    fi
fi

if [ -f /etc/os-release ]; then
    # freedesktop.org and systemd
    . /etc/os-release
    OS=$NAME
    VER=$VERSION_ID
    if [ $OS != "Fedora" ]; then
        echo "This script should be run only on Fedora"
    elif [ $VER -gt "32" ];then
        echo "Downgrading WPA2-Entreprise Wi-FI policies to LEGACY ..."
        sudo update-crypto-policies --set LEGACY
    fi
fi
