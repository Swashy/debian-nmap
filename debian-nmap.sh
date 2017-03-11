#!/bin/bash
#
#<UDF name="pubkey" Label="Enter your public key here" default="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5c8Eyp/+gET8irVN6ck2/eC7jcAaPF7bKJBWbe4w8Df61jwaaBHREH33R65cxOZtC0FRwvOU3uDMyGh+Zqt1Pwab15hmFs98LLZ3ZwPC6GPhIZlAUD78l8ZHV2tW2N4XWBU65Ek3SDOiDg/YHswg2S6lwQ8GlwloNlt9oaydXsZwReJfMqQO6JSj8QN0YdNoeGfC3cipx8H3k3p45dJDtssXu+qlC/lLkpLMuChGG+mMuIGN45Emrb0kEqAfQeGjb5HVN6kg8r0OQi/2YWEauSkFTIy5ghBScEf2C/aveagZASFSdjb5bFT+D/Gm+8IcNYkd5RZaYuxWyK+fExllb"/>
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

mkdir -p /root/.ssh/
touch /root/.ssh/authorized_keys
echo "$publickey" > /root/.ssh/authorized_keys

sed -i.bak "/PasswordAuthentication/ s/yes/no/" /etc/ssh/sshd_config
systemctl restart sshd
