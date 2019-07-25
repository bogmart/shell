#/bin/bash

#sudo apt install cifs-utils

remote_nas_builds=0
build_remote_home="/media/net/k-stufen"
build_remote_smb="//platform-nas.eu.gad.local/K-Stufen"
user_belden="eu.gad.local/mxb11081"

build_local_home="/home/versiuni"
build_local_origin="bogmart_builds"
build_local_branch="p5_shine"

build_home=${build_local_home}

firmware_out=firmware.bin
firmware_input=os32a

usb_sd_aca="ACA|USB|SD|boot|BOOT"
usb_sd_aca_path=$(mount | grep -m 1 -E "(${usb_sd_aca})[^/]* type vfat" | cut -f 3 -d ' ')

print_usage()
{
  echo "$(basename $0) [options]
       -d = debug level (only for local storage)
          default: none (uses symlink/mount point creatd at build time)
          ex:      00 ; 0 ; 2 ; 6
       -f = firmware source name 
          default: ${firmware_input} 
          ex:      msp403a_MR ; grs10403a_MR ; rsp_FACTORY ; HiOS-GRS1040-07000-FTRY07-FACTORY
       -h = help
       -o = firmware destination file name
          default: ${firmware_out} 
          ex:      msp.bin ; ees.bin
       -r = use remote NAS storage
          default: use_local
       -u = different destination 
          default: storage auto detected by pattern: ${usb_sd_aca}
          ex:      /home/bmartinescu/lexar
       -v = different source branch (only for local storage)
          default: ${build_local_branch} 
          ex:      p5_shine ; p5_shine_v6
       -w = different source path (only for local storage)
          default: ${build_local_origin} 
          ex:      bogmart_builds ; official_builds

      Examples:
        $(basename $0)                    -f msp403a_MR
        $(basename $0) -w official_builds -f HiOS-GRS1040-07500-FTRY04-FACTORY      
        $(basename $0) -r                 -f HiOS-GRS1040-07500-FTRY04-FACTORY.bin
      "
}


# parse given parameters
while getopts "d:f:o:u:v:w:hr" opt; do
  case $opt in
    d)
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
      build_local_branch=$OPTARG
      ;;
    w)
      build_local_origin=$OPTARG
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
      build_local_branch=""
      firmware_in_folder=""

    else   #local built images
      #parse image name, e.g: rsp-PRP_FACTORY;  msp3a_MR
      firmware_in_folder=$(echo ${firmware_input} | cut -f 1 -d '-')
      firmware_in_folder=${firmware_in_folder%"_FACTORY"}   #remove "_FACTORY"

      if [ "${firmware_debug}" != "" ]; then 
        firmware_in_folder=${firmware_in_folder}_dbg_${firmware_debug}
      fi

      firmware_in_folder=${firmware_in_folder}/images
    fi

#remote builds: official
else
  if ! mountpoint -q "${build_remote_home}" ; then
    sudo mount -r -t cifs -o username=${user_belden} ${build_remote_smb} ${build_remote_home}
  fi

  build_home=${build_remote_home}
  build_local_origin="PlattformV"
  deviceTmp=$(echo ${firmware_input} | cut -f 2 -d '-' | sed 's/[0-9]//g')
  versionTmp=$(echo ${firmware_input} | cut -f 3 -d '-')
  buildTmp=$(echo ${firmware_input} | cut -f 4 -d '-')

  build_local_branch="v"${versionTmp}/${buildTmp}
  firmware_in_folder=${deviceTmp}
fi


if [ ! -f ${build_home}/${build_local_origin}/${build_local_branch}/${firmware_in_folder}/${firmware_input}.bin ]; then
  echo "NO input firmware!"
  echo
  if [ -d ${build_home}/${build_local_origin}/${build_local_branch}/${firmware_in_folder} ]; then
    echo "Existing files (-f) are: "
    ls -1 ${build_home}/${build_local_origin}/${build_local_branch}/${firmware_in_folder}
  else if [ -d ${build_home}/${build_local_origin}/${build_local_branch} ]; then
    echo "Existing devices/builds are: "
    ls -1 ${build_home}/${build_local_origin}/${build_local_branch}
  else if [ -d ${build_home}/${build_local_origin} ]; then
    echo "Existing origin/builds are: "
    ls -1 ${build_home}/${build_local_origin}
  fi
  fi
  fi
  exit -2
fi


if [ "${usb_sd_aca_path}" == "" ]; then 
  echo "NO ${usb_sd_aca} MOUNTED!"
  exit -1
fi

if [ ! -d ${usb_sd_aca_path} ]; then
  echo "${usb_sd_aca_path}  destination doesn't exist!"
  exit -1
fi


set -x
cp --preserve=timestamps ${build_home}/${build_local_origin}/${build_local_branch}/${firmware_in_folder}/${firmware_input}.bin  ${usb_sd_aca_path}/${firmware_out}
{ set +x; } 2>/dev/null

sync

stat ${usb_sd_aca_path}/${firmware_out} | grep -E "Size:|Modify:" | sed "s/Blocks:.*//; s/\.[0-9]*.*//"


if mountpoint -q "${usb_sd_aca_path}" ; then
  umount ${usb_sd_aca_path}
fi
