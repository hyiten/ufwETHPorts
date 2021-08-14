#!/bin/bash

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

if [[ $1 == '' ]]
then
 until [[ $access == 'allow' || $access == 'deny' ]]
 do
  read -p 'allow/deny :' access
 done
else
 if [[ $1 == 'allow' || $1 == 'deny' ]]
 then
  access=$1
 else
  until [[ $access == 'allow' || $access == 'deny' ]]
  do
   read -p 'allow/deny :' access
  done
 fi
fi


if [[ $2 == '' ]]
then
 read -p 'ip to '$access' :' ipaddr
else
 ipaddr=$2
fi

if valid_ip $ipaddr
then
 echo Setting UFW to $access access for $ipaddr on ETH ports 
else
 echo $ipaddr is not a valid ip address
fi

if [[ -z $access  && -z $ipaddr ]]
then
 echo $access and $ipaddr cannot be accepted
else
 ufw $access proto udp from $ipaddr to any port 30301
 ufw $access proto udp from $ipaddr to any port 30303
 ufw $access proto tcp from $ipaddr to any port 8545
 ufw $access proto tcp from $ipaddr to any port 30301
 ufw $access proto tcp from $ipaddr to any port 30303
 ufw reload
fi
