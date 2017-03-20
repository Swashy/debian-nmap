#!/bin/bash
#
#<UDF name="pubkey" Label="Enter your public key here" default="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5c8Eyp/+gET8irVN6ck2/eC7jcAaPF7bKJBWbe4w8Df61jwaaBHREH33R65cxOZtC0FRwvOU3uDMyGh+Zqt1Pwab15hmFs98LLZ3ZwPC6GPhIZlAUD78l8ZHV2tW2N4XWBU65Ek3SDOiDg/YHswg2S6lwQ8GlwloNlt9oaydXsZwReJfMqQO6JSj8QN0YdNoeGfC3cipx8H3k3p45dJDtssXu+qlC/lLkpLMuChGG+mMuIGN45Emrb0kEqAfQeGjb5HVN6kg8r0OQi/2YWEauSkFTIy5ghBScEf2C/aveagZASFSdjb5bFT+D/Gm+8IcNYkd5RZaYuxWyK+fExllb"/>
#PUBKEY=
ISITUBUNTU=$(lsb_release -a 2>/dev/null | grep 16.04)
#If the last command ran successfuly and there's something returned by grep..
if [ $? -eq 0 && -z "$ISITUBUNTU" ]; then
   ubuntuInstall
fi

ISITDEBIAN=$(lsb_release -d | grep jessie)
if [ $? -eq 0 || -z "$ISITDEBIAN" ]; then
   debianInstall
fi

ISITCENTOS=$(rpm -q centos-release | grep -E centos-release-7+)
if [ $? -eq 0 ] || -z $ISITCENTOS ]; then
  centosInstall
else
  echo "Your distribution is not supported by this StackScript"
  exit
fi

lsb_release -d | grep jessie

debianInstall() {
  apt-get -o Acquire::ForceIPv4=true update -y
  apt-get -o Acquire::ForceIPv4=true install ethtool nmap -y
  mv -bfv /etc/network/.interfaces.linode-orig /etc/network/interfaces
  ethtool -K  eth0  rx off  tx off gso off tso off
  ethtool --show-offload  eth0
  iptables -I OUTPUT -m state --state INVALID -j ACCEPT
  iptables --table raw  -I PREROUTING -m state --state INVALID -j ACCEPT
  iptables --table nat  -I OUTPUT -m state --state INVALID -j ACCEPT
  iptables --table nat  -I POSTROUTING -m state --state INVALID -j ACCEPT
  echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
  echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
  apt-get -o Acquire::ForceIPv4=true install iptables-persistent -y
  systemctl enable iptables-persistent
  mkdir -p /root/.ssh/
  touch /root/.ssh/authorized_keys
  echo "$PUBKEY" >> /root/.ssh/authorized_keys
  sed -i.bak "/PasswordAuthentication/ s/yes/no/" /etc/ssh/sshd_config
  systemctl restart sshd
}
