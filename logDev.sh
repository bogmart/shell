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

#get the device type/family: MSP30 / BRS50
hac_type=`snmpget -v 3 -l authPriv -u admin -a MD5 -A privateprivate -x DES -X privateprivate ${hac_ip} hm2DevMgmtProductDescr.0 | grep -oh  "STRING: [a-zA-Z0-9]*" | sed 's/STRING: //'`


protocol=http
hac_https=`snmpget -v 3 -l authPriv -u admin -a MD5 -A privateprivate -x DES -X privateprivate ${hac_ip} -O vq hm2WebHttpsAdminStatus.0`
if [ "${hac_https}" == "enable" ]
then
  protocol=https
fi

tmpFile=temp_${hac_ip}.html
outFile=develLog_${hac_type}_${hac_ip}-$(date +"%Y.%m.%d-%H.%M.%S").html
outDir=/media/data/logs/dev_logs


#base64auth=`echo ${user}:${pass} | base64`
#wget  --header="Authorization: Basic ${base64auth}"  http://${hac_ip}/download.html?filetype=supportinfo -O ${outDir}/${tmpFile} 


wget --http-user=${user} --http-password=${pass} --no-check-certificate  ${protocol}://${hac_ip}/download.html?filetype=supportinfo -O ${outDir}/${tmpFile}


# check if file exist and it is not empty
if [[ -f ${outDir}/${tmpFile} && -s ${outDir}/${tmpFile} ]]
then
    #echo "${tmpFile} has some data."
    unscramble ${outDir}/${tmpFile}  ${outDir}/${outFile}

    rm ${outDir}/${tmpFile}

    firefox ${outDir}/${outFile} &
else
    echo "file is empty."
    rm ${outDir}/${tmpFile}
fi



