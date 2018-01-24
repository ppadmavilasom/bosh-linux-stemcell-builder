#!/bin/bash

set -ex

#install essentials
tdnf -qy install coreutils findutils cpio util-linux
tdnf -qy install build-essential git sed gawk ncurses-compat tar gzip wget

# ensure the correct kernel headers are installed
tdnf -qy install linux-api-headers

# stemcell image creation
tdnf -qy install kpartx

# native gem dependencies
tdnf -qy install mysql-devel sqlite-devel libxml2-devel libxslt-devel

# vSphere requirements
tdnf -qy install dkms

# needed by stemcell building
tdnf -qy install parted

mkdir -p /mnt/tmp
chown -R photon:photon /mnt/tmp
echo 'export TMPDIR=/mnt/tmp' >> ~photon/.bashrc

# rake tasks will be using this as chroot
mkdir -p /mnt/stemcells
chown -R photon:photon /mnt/stemcells
