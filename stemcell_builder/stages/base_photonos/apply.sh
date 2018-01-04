#!/usr/bin/env bash

set -e

base_dir=$(readlink -nf $(dirname $0)/../..)
source $base_dir/lib/prelude_apply.bash
source $base_dir/etc/settings.bash

rpm --root $chroot --initdb

release_package_url="$(find /mnt/photonos/ -name 'photon-release*.rpm' -print)"
if mountpoint -q /mnt/photonos && [ -n $release_package_url ] ;
then
   echo "PhotonOS ISO is mounted."
else
   echo "PhotonOS ISO is not mounted. Please mount the PhotonOS ISO at /mnt/photonos"
   exit 1
fi

if [ ! -f $chroot/custom_photonos_yum.conf ]; then
  mkdir -p $chroot/etc/yum.repos.d
  cp $base_dir/etc/custom_photonos_yum.conf $chroot/etc/yum.repos.d/base.repo
  cp $base_dir/etc/custom_photonos_yum.conf /etc/yum.repos.d/base.repo
fi

unshare -m $SHELL <<INSTALL_YUM
  set -x
  umask 022
  mkdir -p /etc/pki
  tdnf --installroot=$chroot --disablerepo=* --enablerepo=base -qy install tdnf coreutils sed shadow
INSTALL_YUM

sed -i 's/umask 027/umask 022/' $chroot/etc/profile

if [ ! -d $chroot/mnt/photonos ]; then
  mkdir -p $chroot/mnt/photonos
  mount --bind /mnt/photonos $chroot/mnt/photonos
  add_on_exit "umount $chroot/mnt/photonos"
fi

cp /etc/resolv.conf $chroot/etc/resolv.conf
dd if=/dev/urandom of=$chroot/var/lib/random-seed bs=512 count=1

run_in_chroot $chroot "tdnf --disablerepo=* --enablerepo=base update -qy"
run_in_chroot $chroot "tdnf --disablerepo=* --enablerepo=base install photon-release -qy"
run_in_chroot $chroot "tdnf --disablerepo=* --enablerepo=base -qy install linux-api-headers glibc glibc-devel glibc-lang glibc-i18n zlib zlib-devel file binutils binutils-devel gmp gmp-devel mpfr mpfr-devel mpc coreutils flex bison bindutils sudo e2fsprogs elfutils shadow cracklib Linux-PAM Linux-PAM-devel findutils diffutils sed grep tar gawk which make patch gzip openssl openssl-devel openssh wget vim tdnf curl grub2 grub2-pc tzdata readline-devel ncurses-devel cmake bzip2-devel cdrkit ruby logrotate ntp util-linux cpio"

run_in_chroot $chroot "tdnf --disablerepo=* --enablerepo=base -qy install dracut dkms linux-dev"
run_in_chroot $chroot "tdnf --disablerepo=* --enablerepo=base -qy install systemd rsyslog cronie gcc kpartx pkg-config ncurses bash bzip2 cracklib-dicts shadow procps-ng iana-etc readline coreutils bc libtool inetutils findutils xz iproute2 util-linux ca-certificates iptables attr libcap expat dbus sqlite-autoconf nspr nss rpm libffi gdbm python2 python2-libs pcre glib libxml2 photon-release photon-repos gzip db libsolv libgpg-error hawkey libassuan gpgme librepo tdnf libdnet xerces-c xml-security-c libmspack  krb5 e2fsprogs-devel kmod dhcp-client initscripts libtirpc lsof runit"
#HACK: add linux-esx update
cp $assets_dir/linux-esx-4.9.66-2.ph2.x86_64.rpm $chroot/tmp
run_in_chroot $chroot "rpm -Uvh /tmp/linux-esx-4.9.66-2.ph2.x86_64.rpm"
rm $chroot/tmp/linux-esx-4.9.66-2.ph2.x86_64.rpm
run_in_chroot $chroot "tdnf --disablerepo=* --enablerepo=base -qy install bridge-utils cloud-init cloud-utils libltdl libseccomp libyaml motd net-tools shadow-tools polkit distrib-compat strace iputils patch netmgmt audit openssl-c_rehash"

#cp $assets_dir/bosh-agent-network.* $chroot/usr/lib/systemd/system
#cp $assets_dir/photon-bosh-agent-network.sh $chroot/usr/bin
#run_in_chroot $chroot "systemctl enable bosh-agent-network.path"

#HACK: override dpkg with script.
cp $assets_dir/dpkg $chroot/usr/bin

#HACK: provide update-ca-trust
run_in_chroot $chroot "ln -sf /usr/bin/c_rehash /usr/bin/update-ca-trust"
run_in_chroot $chroot "mkdir -p /etc/pki/ca-trust/source/anchors"

#HACK: make ifup stop complaining of args.
cp $assets_dir/ifup.patch $chroot/
cp $assets_dir/sfdisk $chroot/sbin/sfdisk
run_in_chroot $chroot "patch -p1 < /ifup.patch /sbin/ifup && rm /ifup.patch"

run_in_chroot $chroot "tdnf clean all -q"
run_in_chroot $chroot "touch /etc/machine-id"


touch ${chroot}/etc/sysconfig/network # must be present for network to be configured

# Setting timezone
rm ${chroot}/etc/localtime
cp ${chroot}/usr/share/zoneinfo/UTC ${chroot}/etc/localtime

#generating default locales
run_in_chroot $chroot "/usr/sbin/locale-gen.sh"
# Setting locale
echo "LANG=\"en_US.UTF-8\"" >> ${chroot}/etc/locale.conf

cat >> ${chroot}/etc/login.defs <<-EOF
USERGROUPS_ENAB yes
EOF

#run_in_chroot ${chroot} "systemctl disable systemd-networkd"
#run_in_chroot ${chroot} "sed -i 's|DHCP=yes|DHCP=no\nAddress=10.192.160.2/19\nGateway=10.192.191.253\nDNS=10.195.12.31|' /etc/systemd/network/99-dhcp-en.network"
run_in_chroot ${chroot} "systemctl enable runit"

run_in_chroot ${chroot} "sed -i 's/DROP/ACCEPT/' /etc/systemd/scripts/ip4save"

#Adding system-release file as Specinfra ruby gem can identify PhotonOS as RPM Based Linux Distro
run_in_chroot ${chroot} "touch /etc/system-release"
kernelver=$( ls $chroot/lib/modules )
run_in_chroot ${chroot} "dracut --force --kver ${kernelver}"

#rm -rf $chroot/etc/resolv.conf
#run_in_chroot ${chroot} "ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf"

