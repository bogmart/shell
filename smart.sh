#/bin/bash

logPath=/media/data/logs/smartctl
logFilePrefix="smartctl_$(date +"%Y-%m-%d_%H-%M")"

mkdir -p ${logPath}

for drive in /dev/sd[a-z][1] /dev/nvme[0-9]
do
   if [[ ! -e $drive ]]; then continue ; fi

   driveShortName=$(echo "${drive}" | cut -d'/' -f 3)
   logFile=${logFilePrefix}_${driveShortName}".txt"
   echo ${logFile}

   sudo smartctl --all "${drive}" > ${logPath}/${logFile}

done


