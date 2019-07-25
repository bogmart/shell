#/bin/bash

hac_ip=10.0.0.2
user=admin
pass=private

case "$1" in
  -h|--h|-help|--help|/?)
    echo "Usage: $(basename $0)  [HAC_IP_Address]" >&2
    echo "    ( default IP: ${hac_ip} )" >&2
    exit 2
  ;;
esac


if [ ! -z "$1" ]
then
 hac_ip=$1
fi

hac_type=`snmpget  -v 2c -c private ${hac_ip} hm2DevMgmtProductDescr.0 | grep -oh  "STRING: [a-zA-Z0-9]*" | sed 's/STRING: //'`

tmpFile=temp_${hac_ip}.html
outFile=develLog_${hac_type}_${hac_ip}-$(date +"%Y.%m.%d-%H.%M.%S").html
outDir=~/Documents/dev_logs


#base64auth=`echo ${user}:${pass} | base64`
#wget  --header="Authorization: Basic ${base64auth}"  http://${hac_ip}/download.html?filetype=supportinfo -O ${outDir}/${tmpFile} 


wget  --http-user=${user} --http-password=${pass}  http://${hac_ip}/download.html?filetype=supportinfo -O ${outDir}/${tmpFile} 

# check if file exist and it is or empty
if [[ -f ${outDir}/${tmpFile} && -s ${outDir}/${tmpFile} ]]
then
    echo "$_file has some data."
    unscramble ${outDir}/${tmpFile}  ${outDir}/${outFile}

    rm ${outDir}/${tmpFile}

    firefox ${outDir}/${outFile} &
else
    echo "file is empty."
    rm ${outDir}/${tmpFile}
fi



