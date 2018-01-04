#!/usr/bin/env bash
#
# Copyright (c) 2009-2012 VMware, Inc.

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash

pushd $work/ovf
chown photon:photon image.ovf
chown photon:photon image.mf
chown photon:photon image-disk1.vmdk
tar zcf ../stemcell/image image.ovf image.mf image-disk1.vmdk
chown photon:photon ../stemcell/image
popd
