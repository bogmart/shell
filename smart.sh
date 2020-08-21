#/bin/bash

#sudo gedit /etc/anacrontab
#  7	30	cron.smartctl	/home/bmartinescu/scripts/smart.sh
#sudo tail  /var/spool/anacron/cron.*
#ls -rla /etc/cron*

logPath=/media/data/logs/smartctl
logFilePrefix="smartctl_$(date +"%Y-%m-%d_%H-%M")"
logFileShort=${logFilePrefix}_overview".txt"
logFileFsTrim=${logFilePrefix}_fstrim".txt"


mkdir -p ${logPath}


printf "Total Bytes Writte\n------------------\n" > ${logPath}/${logFileShort}

sectorSize=512
sectorSizeCorrection=24.6

for drive in /dev/sd*[a-z] /dev/nvme[0-9]
do
   if [[ ! -e $drive ]]; then continue ; fi

   driveShortName=$(echo "${drive}" | cut -d'/' -f 3)
   logFile=${logFilePrefix}_${driveShortName}".txt"
   echo ${logFile}
   sudo smartctl --all "${drive}" > ${logPath}/${logFile}

   writtenLine=$( sudo smartctl --all "${drive}" | grep "Written" )
   if [ -n "$writtenLine" ]; then
     if [[ ${drive} == *"nvme"* ]]; then
       writenBytes=$( echo ${writtenLine} | sed -E 's/.* ([0-9,]*)( \[.*)/\1/;s/,//g' | awk -v size=${sectorSize} -v correction=${sectorSizeCorrection} '{print $1 * 1024 * (size + correction) }' )
     else
       writenBytes=$( echo ${writtenLine} | sed -E 's/.* ([0-9,]*)/\1/' | awk -v size=${sectorSize} '{print $1 * size }' )
     fi

     writenBytes=`echo ${writenBytes} | awk 'function human(x) { if (x[1]>=1024) { x[1]/=1024; x[2]++; { human(x) }}} {a[1]=$1; a[2]=0; human(a); printf("%f %sB\n",a[1],substr("BkMGTEPYZ",a[2]+1,1))}'`
     printf "%s\t%7.3f %s\n" ${drive}  ${writenBytes}                     >> ${logPath}/${logFileShort}
   fi

done

printf "\n"                                                                               >> ${logPath}/${logFileShort}
sudo /home/bmartinescu/tools/Samsung_SSD_DC_Toolkit_for_Linux_V2.1   --list 2>/dev/null   >> ${logPath}/${logFileShort}


#sudo journalctl -u fstrim.service                                                        > ${logPath}/${logFileFsTrim}
sudo zgrep "fstrim" /var/log/syslog* | sed 's/[^ ]*://' | tac                             > ${logPath}/${logFileFsTrim}


echo
echo see  ${logPath}/ help.txt



