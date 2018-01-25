#!/usr/bin/env bash

for package_name in \
  build-essential \
  autoconf \
  bison \
  cmake \
  cpp \
  flex \
  gcc \
  gettext \
  intltool \
  mpc \
  libstdc++-devel \
  make \
  patch \
; do
  rpm -ql $package_name | xargs file | grep -Ev ':\s+directory\s+$' | awk -F ':' '{ print $1 }'
done
