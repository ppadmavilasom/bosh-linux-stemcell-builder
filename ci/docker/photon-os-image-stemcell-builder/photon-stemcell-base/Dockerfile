# vmware/photon-stemcell-base
# base container with stemcell build tools

FROM vmware/photon:2.0rc

RUN tdnf erase toybox -qy
RUN tdnf install sed shadow -qy
RUN tdnf update -qy --refresh
RUN sed -i 's/umask 027/umask 022/' /etc/profile
#basic deps
RUN tdnf install -qy \
        build-essential git util-linux \
        curl wget \
        tar gzip bzip2 \
        findutils gawk which sed \
        gdbm-devel openssl-devel readline-devel zlib-devel
#ruby deps
RUN tdnf install -qy libxslt-devel libxml2-devel
ADD install-ruby.sh /tmp/install-ruby.sh
RUN chmod a+x /tmp/install-ruby.sh
RUN cd /tmp && ./install-ruby.sh && rm install-ruby.sh

#go
RUN tdnf install -qy go
