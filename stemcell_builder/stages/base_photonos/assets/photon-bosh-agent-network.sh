#!/bin/bash
set -x
echo 'ifcfg file changed'
interface=eth0

ifcfgfile=/etc/sysconfig/network-scripts/ifcfg-$interface
cat $ifcfgfile

if [ -e $ifcfgfile ]
then

source /etc/sysconfig/network-scripts/ifcfg-$interface

  if [ -n "$IPADDR" ]
  then
  netmgr ip4_address --set --interface $interface --mode $BOOTPROTO --addr $IPADDR/19 --gateway $GATEWAY
  netmgr dns_servers --set --mode dhcp --servers $DNS1
  else
   echo 'ipaddr is empty'
   exit 1
  fi
fi
