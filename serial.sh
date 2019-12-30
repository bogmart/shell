#/bin/bash

# manual pre-config
#  ~/.minirc.dfl
#       pu statusline       disabled

logPath=/media/data/logs/console_logs
logFile="$1_$(date +"%Y-%m-%d_%H-%M").txt"

mkdir -p ${logPath}

case "$1" in
  brs)
    baudRate=115200
    ttyDevice=/dev/ttyACM0
    #ttyDevice=/dev/serial/by-id/usb-Hirschmann_Automation+Control_BRS20-0400_B2_77-if02
    #ttyDevice=/dev/serial/by-id/usb-Hirschmann_Automation+Control_BRS50-00122Q2Q-STCZ99HHSES_942170999000201851-if02
  ;;

  rsp|rsps|rspl|rspe)
    baudRate=9600
    ttyDevice=/dev/ttyS3
  ;;

  ees|msp|os|grs)
    baudRate=9600
    ttyDevice=/dev/ttyS1
  ;;

  usb|dragon)
    baudRate=9600
    #ttyDevice=/dev/ttyUSB0
    #ttyDevice=/dev/ttyUSB1
    ttyDevice=/dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller_D-if00-port0
  ;;

  *)
    echo "Usage: $(basename -- "$0") {brs|dragon|grs|msp|os|rsp|rspl|rspe|rsps} [options]" >&2
    echo "Ex   : $(basename -- "$0") dragon                           -b 115200" >&2
    exit 2
  ;;
esac

otherOptions="$2 $3 $4 $5 $6 $7"

minicom -D ${ttyDevice} -w -b ${baudRate} -C ${logPath}/${logFile} ${otherOptions}

