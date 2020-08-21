#/bin/bash

#sudo apt install cifs-utils sshfs

build_main="/media/data/versiuni"

build_local_origin="bogmart_builds"
build_local_branch="p5_shine"

build_remote_folder="k-stufen"
build_remote_origin=${build_remote_folder}/"PlattformV"
build_remote_prefix="v"
build_remote_branch=${build_remote_prefix}"99999"
build_remote_dev="development"


#default
remote_nas_builds=0
build_origin=${build_local_origin}
build_branch=""


build_remote_smb="//platform-nas.eu.gad.local/K-Stufen"
user_belden="EUGAD/rnt-setups"
pass_belden="rnt-setups"

#SFTP mount is faster than the samba one
build_remote_sftp="platform-nas.eu.gad.local"
user_belden="k-stufen-ro"
pass_belden=""


firmware_out=firmware.bin
firmware_input=os22a
firmware_dst=USB

# FTP server (local on PC)
user_name=user
user_pass=pass

# DUT SNMPv3
dut_user=admin
dut_pass=privateprivate


usb_sd_aca="ACA|USB|SD|boot|BOOT"
usb_sd_aca_path=$(mount | grep -m 1 -E "(${usb_sd_aca})[^/]* type vfat" | cut -f 3 -d ' ')

print_usage()
{
  echo "$(basename $0) [options]
       -d = destination: <IP address> or USB
          default: ${firmware_dst}
          ex:      10.10.10.1 ; 10:10:10::1 ; USB
       -D = debug level (only for local storage)
          default: none (uses symlink/mount point creatd at build time)
          ex:      00 ; 0 ; 2 ; 6
       -f = firmware source name 
          default: ${firmware_input} 
          ex:      rsp.bin ; msp403a_MR ; rsp_FACTORY ; HiOS-GRS1040-07000-FTRY07-FACTORY
       -h = help
       -o = firmware destination file name (only for destination USB)
          default: ${firmware_out} 
          ex:      msp.bin ; ees.bin
       -r = copy from remote NAS storage
          default: use_local
       -u = different destination (only for destination USB)
          default: storage auto detected by pattern: ${usb_sd_aca}
          ex:      /home/bmartinescu/lexar
       -v = different source branch
          default: ${build_local_branch} (local)   none (remote)
          ex:      local:   p5_shine ; p5_shine_work
                   remote:  iceberg ; orion
       -w = different source path (only for local storage)
          default: ${build_origin} 
          ex:      bogmart_builds ; official_builds

      Examples:
        $(basename $0)    -f msp403a_MR                         -d 10.20.20.20
        $(basename $0)    -f HiOS-RSPS-06100.bin                -d USB         -w official_builds     
        $(basename $0) -r -f HiOS-GRS1040-07500-FTRY04-FACTORY  -d USB         
        $(basename $0) -r -f HiOS-GRS1040-99999-BETA01          -d USB         -v orion
      "
}

timeStart=`date +%s`

# parse given parameters
while getopts "d:D:f:o:u:v:w:hr" opt; do
  case $opt in
    d)
      # converting to uppercase: usb -> USB
      firmware_dst=${OPTARG^^}
      ;;
    D)
      firmware_debug=$OPTARG
      ;;
    f)
      firmware_input=$OPTARG
      firmware_input=${firmware_input%".bin"}   #remove ".bin"
      ;;
    o)
      firmware_out=$OPTARG
      ;;
    u)
      usb_sd_aca_path=$OPTARG
      ;;
    r)
      remote_nas_builds=1
      ;;
    v)
      build_branch=$OPTARG
      ;;
    w)
      build_origin=$OPTARG
      ;;
    h)
      print_usage
      exit 0
      ;;
    ?)
      echo ""
      print_usage
      exit 1
      ;;
  esac
done



#update path for local/official builds

#local builds: official or development
if [ ${remote_nas_builds} == 0 ]; then

  #official images: HiOS-GRS1040-07000-FTRY07-FACTORY.bin
  if [[ ${firmware_input} == "HiOS"* ]]; then  
    #ToDo: parse HiOS-2S-RSP-07202-FTRY03-FACTORY.bin
    build_branch=""
    firmware_in_folder=""

  else   #local built images
    build_branch=${build_local_branch}

    #parse image name, e.g: rsp-PRP_FACTORY;  msp3a_MR
    firmware_in_folder=$(echo ${firmware_input} | cut -f 1 -d '-')
    firmware_in_folder=${firmware_in_folder%"_FACTORY"}   #remove "_FACTORY"

    if [ "${firmware_debug}" != "" ]; then 
      firmware_in_folder=${firmware_in_folder}_dbg_${firmware_debug}
    fi

    firmware_in_folder=${firmware_in_folder}/images
  fi

  build_release=""
  build_home=${build_main}/${build_origin}

#remote builds: official
else
  if ! mountpoint -q "${build_main}/${build_remote_folder}" ; then
    #sudo mount -r -t cifs -o username=${user_belden},password=${pass_belden}  ${build_remote_smb} ${build_main}/${build_remote_folder}
    sudo sshfs -o allow_other -o reconnect -o ServerAliveInterval=15 ${user_belden}@${build_remote_sftp}:/  ${build_main}/${build_remote_folder}
  fi

  ##parse the device: eg GRS, RSP
  posIter=2
  deviceTmp=$(echo ${firmware_input} | cut -f ${posIter} -d '-')
  posIter=$(( posIter + 1 ))
  ###skip special case: 2S
  firstLetter=${deviceTmp:0:1}
  if  [[ ${firstLetter} =~ [0-9] ]]; then
    deviceTmp=$(echo ${firmware_input} | cut -f ${posIter} -d '-')
    posIter=$(( posIter + 1 ))
  fi
  ###strip numbers: eg GRS1020_1030, OCTOPUS3 
  deviceTmp=$(echo ${deviceTmp} | sed 's/[0-9_]//g')

  ##parse version: BETA14, FTRY01
  versionTmp=$(echo ${firmware_input} | cut -f ${posIter} -d '-')
  posIter=$(( posIter + 1 ))
  ###check for FPGA version: PRP, MRP
  firstLetter=${versionTmp:0:1}
  if  [[ ! ${firstLetter} =~ [0-9] ]]; then
    versionTmp=$(echo ${firmware_input} | cut -f ${posIter} -d '-')
    posIter=$(( posIter + 1 ))
  fi
  
  ##parse build: NTLY12, FINAL.BETA14
  buildTmp=$(echo ${firmware_input} | cut -f ${posIter} -d '-')
  posIter=$(( posIter + 1 ))

  firmware_in_folder=${deviceTmp}

  build_origin=${build_remote_origin}

  #/development/bell/...
  if [ "${build_branch}" != "" ]; then
    build_branch=${build_remote_dev}/${build_branch}
  else
    build_branch=${build_remote_prefix}${versionTmp}
  fi

  build_release=${buildTmp}
  build_home=${build_main}/${build_remote_origin}
fi


if [ "${debug}" == "1" ]; then
  echo build_home:         ${build_home}
  echo build_branch:       ${build_branch}
  echo build_release:      ${build_release}
  echo firmware_in_folder: ${firmware_in_folder}
  echo firmware_input:     ${firmware_input}
  exit 10
fi


if [ ! -f ${build_home}/${build_branch}/${build_release}/${firmware_in_folder}/${firmware_input}.bin ]; then
  echo "NO input firmware!" ${build_home}/${build_branch}/${build_release}/${firmware_in_folder}/${firmware_input}.bin
  echo
  if [ -d ${build_home}/${build_branch}/${build_release}/${firmware_in_folder} ]; then
    echo "Existing files (-f) are: "
    ls -1 ${build_home}/${build_branch}/${build_release}/${firmware_in_folder}
  else if [ -d ${build_home}/${build_branch}/${build_release} ]; then
    echo "Existing devices/builds are: "
    ls -1 ${build_home}/${build_branch}/${build_release}  | grep -vE "mibs|log"
  else if [ -d ${build_home}/${build_branch} ]; then
    echo "Existing origin/builds are: "
    ls -1 ${build_home}/${build_branch}  | grep -vE "web|xml"
  else if [ -d ${build_home} ]; then
    echo "Existing origin/versions are: "
    if [[ ${build_branch} =~ ${build_remote_dev}.* ]] && [ -d ${build_home}/${build_remote_dev} ]; then
      ls -1 ${build_home}/${build_remote_dev}
    else
      ls -1 ${build_home}  | grep -E "^v|^Hi"
    fi
  fi
  fi
  fi
  fi
  exit -2
fi


# copy to USB/SD
if [ ${firmware_dst} == USB ]; then 
  if [ "${usb_sd_aca_path}" == "" ]; then 
    echo "NO ${usb_sd_aca} MOUNTED!"
    exit -1
  fi

  if [ ! -d ${usb_sd_aca_path} ]; then
    echo "${usb_sd_aca_path}  destination doesn't exist!"
    exit -1
  fi

  set -x
  cp --preserve=timestamps ${build_home}/${build_branch}/${build_release}/${firmware_in_folder}/${firmware_input}.bin  ${usb_sd_aca_path}/${firmware_out}
  #rsync -ah --progress ${build_home}/${build_branch}/${build_release}/${firmware_in_folder}/${firmware_input}.bin  ${usb_sd_aca_path}/${firmware_out}
  { set +x; } 2>/dev/null

  sync

  stat ${usb_sd_aca_path}/${firmware_out} | grep -E "Size:|Modify:" | sed "s/Blocks:.*//; s/\.[0-9]*.*//"


  if mountpoint -q "${usb_sd_aca_path}" ; then
    umount ${usb_sd_aca_path}
  fi

# copy to remote IP
else
  hac_ip=${firmware_dst}
  serv_ip=`ip route get ${firmware_dst} | head -1 | sed 's/.*src \([0-9a-fA-F.:]*\)[ ]*.*/\1/'`
  
  path_bin_file=ftp://${serv_ip}/${build_origin}/${build_branch}/${build_release}/${firmware_in_folder}/${firmware_input}.bin
  echo ${path_bin_file}

  snmpset -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} ${hac_ip} hm2FMServerUserName.0   s ${user_name}            > /dev/null 2>&1
  snmpset -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} ${hac_ip} hm2FMServerPassword.0   s ${user_pass}            > /dev/null 2>&1
  snmpset -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} ${hac_ip} hm2FMActionSourceData.0 s ${path_bin_file}        > /dev/null 2>&1

  actionActivate=`snmpget -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} -O vq  ${hac_ip} hm2FMActionActivateKey.0`
  snmpset -t 40 -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} ${hac_ip} hm2FMActionActivate.copy.firmware.server.system i ${actionActivate}   > /dev/null 2>&1
  #echo ${actionActivate}

  actionStatus=idle
  while [ "${actionStatus}" == "idle" ]; do
    actionStatus=`snmpget -t 10 -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} -O vq ${hac_ip} hm2FMActionStatus.0`
    sleep 1
    echo "${actionStatus}"
  done

  percentReady=0
  while [ "${actionStatus}" == "running" ]; do
    actionStatus=`snmpget -t 5 -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} -O vq ${hac_ip} hm2FMActionStatus.0`
    percentReady=`snmpget -t 5 -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} -O vq ${hac_ip} hm2FMActionPercentReady.0`
    echo -ne ${percentReady}'\r'
    sleep 1
  done
  echo -e '\n'

  actionResult=`snmpget -t 5 -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} -O vq ${hac_ip} hm2FMActionResult.0`
  if [ "${actionResult}" == "ok" ] ; then
    echo -n "reboot...  "
    actionReset=2 # (1 = other, 2 = reset)
    snmpset -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} ${hac_ip} hm2DevMgmtActionReset.0 i ${actionReset}           > /dev/null 2>&1
  else
    actionResultText=`snmpget -v 3 -l authPriv -u ${dut_user} -a MD5 -A ${dut_pass} -x DES -X ${dut_pass} -O vq ${hac_ip} hm2FMActionResultText.0`   > /dev/null 2>&1
    echo ERR: ${actionResultText}
  fi

fi

timeEnd=`date +%s`
timeRun=$((timeEnd-timeStart))
echo -e  "done after " ${timeRun} " sec" '\n'

