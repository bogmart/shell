#/bin/bash

logPath=/home/console_logs
logFile="$1_$(date +"%Y-%m-%d_%H-%M").txt"

set-title() {
  ORIG=$PS1
  TITLE="\e]2;$@\a"
  PS1=${ORIG}${TITLE}
}

mkdir -p ${logPath}

case "$1" in
  dragon1)
    #dragon testare / Marius / Seb
    termSrvIp=10.2.36.249
    termSrvPort=5006
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
