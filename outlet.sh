#/bin/bash

outletMAC=00:0A:9C:53:94:37
outletIpV4=192.168.1.254
outletIpV6=fe80::20a:9cff:fe53:9437
#telnet -6 fe80::20a:9cff:fe53:9437%eth0


outletIp=${outletIpV4}

case "$1" in
  on)
    action=1
  ;;

  off)
    action=2
  ;;

  *)
    echo "Usage: $(basename -- "$0") {on|off}" >&2
    exit 2
  ;;
esac

#set port 
for port in {1..8}
do
  snmpset -v2c -cprivate ${outletIp} Sentry3-MIB::outletControlAction.1.1.${port}  i ${action}
done

sleep 0.5

#get status
snmpwalk -v2c -cprivate ${outletIp} Sentry3-MIB::outletStatus.1.1


