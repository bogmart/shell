#/bin/bash

logPath=/media/data/logs/console_logs
logFile="$1_$(date +"%Y-%m-%d_%H-%M").txt"


set-title() { printf "\033]0;$*\007"; }


mkdir -p ${logPath}

case "$1" in
  dragon1)
    #dragon testare / Marius / Seb
    termSrvIp=10.2.36.249
    termSrvPort=5006
  ;;

  m4002xg)
    termSrvIp=10.2.36.241
    termSrvPort=5008
  ;;

  msp20)
    termSrvIp=10.2.36.238
    termSrvPort=5014
  ;;

  msp21)
    termSrvIp=10.2.36.238
    termSrvPort=5015
  ;;

  msp22)
    termSrvIp=10.2.36.238
    termSrvPort=5016
  ;;


  *)
    echo "Usage: $(basename -- "$0") {dragon1|msp20|msp21|msp22}" >&2
    exit 2
  ;;
esac

#rename the tab
set-title $1

telnet ${termSrvIp}  ${termSrvPort}  | tee -a -i ${logPath}/${logFile}
