# vmware/photon-os-image-stemcell-builder

#move this to bosh/photon-stemcell-base
FROM ppadmavilasom/photon-stemcell-base

RUN tdnf install e2fsprogs cloud-init cronie rpm rsync sed shadow sudo -qy --refresh
RUN umask 022
RUN sed -i 's/umask 027/umask 022/' /etc/profile
RUN touch /etc/at.allow
RUN touch /etc/cron.allow
RUN touch /etc/crontab

RUN groupadd -g 1000 photon && useradd -u 1000 -g 1000 -m photon && echo 'photon ALL=NOPASSWD:ALL' >> /etc/sudoers

ADD scripts/update.sh /tmp/update.sh
RUN /tmp/update.sh && rm /tmp/update.sh

ENV OVF_TOOL_INSTALLER VMware-ovftool-4.1.0-2459827-lin.x86_64.bundle
ENV OVF_TOOL_INSTALLER_SHA1 b907275c8d744bb54717d24bb8d414b19684fed4
ADD ${OVF_TOOL_INSTALLER} /tmp/ovftool_installer.bundle
ADD scripts/install-ovf.sh /tmp/install-ovf.sh
RUN /tmp/install-ovf.sh && rm /tmp/install-ovf.sh

RUN wget -O /usr/bin/meta4 https://github.com/dpb587/metalink/releases/download/v0.2.0/meta4-0.2.0-linux-amd64 \
  && echo "81a592eaf647358563f296aced845ac60d9061a45b30b852d1c3f3674720fe19  /usr/bin/meta4" | shasum -a 256 -c \
  && chmod +x /usr/bin/meta4

ADD scripts/photon_bashrc /home/photon/.bashrc

#RUN for GO_EXECUTABLE in $GOROOT/bin/*; do ln -s $GO_EXECUTABLE /usr/bin/; done
CMD ["/bin/bash", "-l"]
