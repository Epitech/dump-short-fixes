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
    dnf install kernel "kernel-*"
    dnf upgrade kernel "kernel-*"
    dnf install dkms
    git clone https://github.com/tomaspinho/rtl8821ce.git
    cd rtl8821ce
    ./dkms-install.sh
    echo $PCI_NAME " drivers installed in rtl8821ce directory, you are free to delete it."
fi