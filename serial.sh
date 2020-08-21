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
    #ttyDevice=/dev/serial/by-id/usb-Hirschmann_Automation_and_Control_GmbH_*
  ;;

  rsp|rsps|rspl|rspe)
    baudRate=9600
    ttyDevice=/dev/ttyS3
  ;;

  ees|msp|os|grs|dragon)
    baudRate=9600
    ttyDevice=/dev/ttyS1
  ;;

  usb)
    baudRate=115200
    ttyDevice=/dev/ttyUSB0
    #ttyDevice=/dev/serial/by-id/usb-FTDI_*
  ;;

  usb1)
    baudRate=9600
    #ttyDevice=/dev/ttyUSB0
    #ttyDevice=/dev/ttyUSB1
    ttyDevice=/dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller_*
  ;;

  *)
    echo "Usage: $(basename -- "$0") {brs|dragon|grs|msp|os|rsp|rspl|rspe|rsps|usb} [options]" >&2
    echo "Ex   : $(basename -- "$0") dragon                           -b 115200" >&2
    exit 2
  ;;
esac

otherOptions="$2 $3 $4 $5 $6 $7"

minicom -D ${ttyDevice} -w -b ${baudRate} -C ${logPath}/${logFile} ${otherOptions}

