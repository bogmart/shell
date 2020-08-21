#!/bin/bash

#export USER=uxs11111
#export USERNAME=uxs11111

#RED='\033[0;31m'
#NoColo='\033[0m'
#echo -e "${RED} !!! Please SET !! \n\n SHINE_SHARED_DIR=/media/ssd/git_hm_sources/p5_hirschmann_shared_work \n ${NoColo}"

print_usage()
{
  echo "$(basename $0) {options}
       -l = env for linux
       -v = env for vxWork
       -w = git worktree 
      "
}

if [ -z "$1" ] 
then
  print_usage
  exit 1
fi

# parse given parameters
while getopts "lvwh " opt; do
  case ${opt} in
    l)
      buildType="linux"
      ;;
    v)
      buildType="vxworks"
      ;;
    w)
      workSuffix="_work"
      ;;
    *)
      echo ""
      print_usage
      exit 2
      ;;
  esac
done

wind_linux=/media/ssd/WindRiver${workSuffix}
shine_dir=/media/ssd/git_hm_sources/p5_smart_shine${workSuffix}
export SHINE_SHARED_DIR=/media/ssd/git_hm_sources/p5_hirschmann_shared${workSuffix}
export WEB_SOURCE_DIR=/media/ssd/git_hm_sources/p5_gwt_webif${workSuffix}
export WEB_HELP_DIR=/media/ssd/git_hm_sources/p5_web_help${workSuffix}
export LINUX_BASE_DIR=/media/ssd/git_hm_sources/p5_linux_kernel${workSuffix}


export TMPDIR=/media/ssd/TMPDIR
export TEMP=/media/ssd/TMPDIR
export TMP=/media/ssd/TMPDIR

cd ${shine_dir}

case ${buildType} in
  "vxworks")
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${wind_linux}/workbench-3.3/foundation/x86-linux2/lib:${wind_linux}/lmapi-5.0/x86-linux2/lib
    ${wind_linux}/workbench-3.3/foundation/x86-linux2/bin/wtxregd restart
    ${wind_linux}/wrenv.linux -p vxworks-6.9 
    ;;

  "linux")
    bash
    ;;
esac








