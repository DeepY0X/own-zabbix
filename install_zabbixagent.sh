#!/bin/bash
# Author: Ernie Rojas
# email: erniervx@gmail.com
# Script to install Zabbix Agent in Linux rpm-based 


fileconf="/mnt/zabbix_agentd.conf"
id_user=`id -u`
nfsserver="ip nfs server"
clientname=`hostname`
zabbixserver="ip zabbix server"

if [ $id_user -ne 0 ]; then
	echo "Run script as root"
	exit 1
fi

ping -c1 google.com
if [ $? -eq 0 ]; then
	rpm -ivh http://repo.zabbix.com/zabbix/2.4/rhel/6/x86_64/zabbix-release-2.4-1.el6.noarch.rpm
	yum -y check-update
	yum -y install zabbix-agent
	mount | grep $nfsserver
	if [ $? -eq 0 ]; then
		cp /etc/zabbix/zabbix_agentd.conf /etc/zabbix/zabbix_agentd.conf.orig
		sed "s/hostnameclient/$clientname/g" $fileconf > /etc/zabbix/zabbix_agentd.conf
		sed "s/ipzabbixserver/$zabbixserver/g" $fileconf > /etc/zabbix/zabbix_agentd.conf
  		chkconfig zabbix-agent on
		service zabbix-agent start
	else
		echo "Problems copying your config file"
		exit 1
	fi
echo "Zabbix Agent successfull!"
echo "If you have firewall enabled, add the next rule to your iptables firewall in /etc/sysconfig/iptables and reload"
echo "-A INPUT -m state --state NEW -m tcp -p tcp --dport 10050 -j ACCEPT"
echo 
else
	echo "Problems with your internet connection!"
	exit 1
fi 