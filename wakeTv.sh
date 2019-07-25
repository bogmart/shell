#/bin/bash

apricoiu_nb_mac=54:EE:75:18:98:80
apricoiu_nb_ip=10.2.36.89
apricoiu_nb_bcast=10.2.36.255

#  echo "(^C to quit)"
while :
do
  wakeonlan -i ${apricoiu_nb_bcast} ${apricoiu_nb_mac}
  ping -W 1 -c 1 ${apricoiu_nb_ip}
  if [ $? == 0 ]; then
   echo "start VNC to ${apricoiu_nb_ip}"
   vinagre --vnc-scale  ${apricoiu_nb_ip} &
   break
  fi
  
  
done




