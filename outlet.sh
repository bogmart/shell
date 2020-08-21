#/bin/bash

outletMAC=00:0A:9C:53:94:37
outletIpV4=192.168.1.254
outletIpV6=fe80::20a:9cff:fe53:9437
#telnet -6 fe80::20a:9cff:fe53:9437%eth0

outletIp=${outletIpV4}


help_usage()
{
  echo "Usage: $(basename -- "$0") {on|off} {all|d1|d2|disp}" >&2
  exit 1
}


case "$1" in
  on)
    action=1
  ;;

  off)
    action=2
  ;;

  *)
    help_usage
  ;;
esac


case "$2" in
  all)
    port_start=1
    port_end=8
  ;;

  d1)
    # devices No #1
    port_start=3
    port_end=3
  ;;

  d2)
    # devices No #2
    port_start=4
    port_end=4
  ;;

  disp)
    # monitors
    port_start=1
    port_end=2
  ;;

  *)
    help_usage
  ;;
esac


#set port 
for port in  $(seq ${port_start} ${port_end})
do
  snmpset -v2c -cprivate ${outletIp} Sentry3-MIB::outletControlAction.1.1.${port}  i ${action}
done

sleep 0.5

echo "get status"
for port in  $(seq ${port_start} ${port_end})
do
 snmpget -v2c -cprivate ${outletIp} Sentry3-MIB::outletStatus.1.1.${port}
done

exit 0




