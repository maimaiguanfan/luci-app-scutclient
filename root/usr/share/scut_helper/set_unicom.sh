#!/bin/sh
export PATH="/bin:/sbin:/usr/sbin:/usr/bin"


#如果没有接口就定义
if=`uci get network.unicom`
if [ ! -n "$if" ]; then 
    echo "create l2tp" 
    uci set network.unicom=interface
    uci set network.unicom.proto='l2tp'
    uci set network.unicom.ipv6='auto'
    wan_zone=`uci show firewall|grep zone|grep name=\'wan\'|awk -F"." '{print $2}'`
    uci add_list firewall.${wan_zone}.network='unicom'
fi 
    
uci set network.unicom.server=`uci get scutclient.@option[0].unicom_username`
uci set network.unicom.username=`uci get scutclient.@option[0].unicom_password`
uci set network.unicom.password=`uci get scutclient.@option[0].unicom_server`
uci commit

ifup unicom

IP_FILE="/usr/share/scut_helper/scut_route.txt"
GATEWAY=`uci get network.wan.gateway`
#以下是教育网内网地址分流
cat $IP_FILE|while read -r IP MASK; do
route add -net $IP netmask $MASK gw $GATEWAY dev eth1
done
return 0