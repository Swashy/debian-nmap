#!/bin/bash
#<UDF name="pubkey" Label="Enter your public key here" default=""/>
#
apt-get -o Acquire::ForceIPv4=true update -y
apt-get -o Acquire::ForceIPv4=true install ethtool nmap -y

mv -bfv /etc/network/.interfaces.linode-orig /etc/network/interfaces

ethtool -K  eth0  rx off  tx off gso off tso off
ethtool --show-offload  eth0

iptables -I OUTPUT -m state --state INVALID -j ACCEPT
iptables --table raw  -I PREROUTING -m state --state INVALID -j ACCEPT
iptables --table nat  -I OUTPUT -m state --state INVALID -j ACCEPT
iptables --table nat  -I POSTROUTING -m state --state INVALID -j ACCEPT
yes | sudo apt-get purge iptables-persistent -y
