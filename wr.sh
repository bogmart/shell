#!/bin/bash

#export USER=uxs11111
#export USERNAME=uxs11111

#RED='\033[0;31m'
#NoColo='\033[0m'
#echo -e "${RED} !!! Please SET !! \n\n SHINE_SHARED_DIR=/media/ssd/git_hm_sources/p5_hirschmann_shared_work \n ${NoColo}"

#echo "argument(s) supplied: " $1
if [ ! -z "$1" ] 
then
  wind_linux=/media/ssd/WindRiver_work
  shine_dir=/media/ssd/git_hm_sources/p5_smart_shine_work
  export SHINE_SHARED_DIR=/media/ssd/git_hm_sources/p5_hirschmann_shared_work 
else
  wind_linux=/media/ssd/WindRiver
  shine_dir=/media/ssd/git_hm_sources/p5_smart_shine
  export SHINE_SHARED_DIR=/media/ssd/git_hm_sources/p5_hirschmann_shared
fi

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${wind_linux}/workbench-3.3/foundation/x86-linux2/lib:${wind_linux}/lmapi-5.0/x86-linux2/lib

export TMPDIR=/tmp/


${wind_linux}/workbench-3.3/foundation/x86-linux2/bin/wtxregd restart

cd ${shine_dir}

${wind_linux}/wrenv.linux -p vxworks-6.9 

