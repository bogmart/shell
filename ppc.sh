#!/bin/bash

#RED='\033[0;31m'
#NoColo='\033[0m'
#echo -e "${RED} !!! Please SET !! \n\n SHINE_SHARED_DIR=/media/ssd/git_hm_sources/p5_hirschmann_shared_work \n ${NoColo}"

export WEB_HELP_DIR=/media/ssd/git_hm_sources/p5_web_help
export LINUX_BASE_DIR=/media/ssd/git_hm_sources/p5_linux_kernel

#echo "argument(s) supplied: " $1
if [ ! -z "$1" ] 
then
  shine_dir=/media/ssd/git_hm_sources/p5_smart_shine_work
  export SHINE_SHARED_DIR=/media/ssd/git_hm_sources/p5_hirschmann_shared_work
  #export WEB_HELP_DIR=/media/ssd/git_hm_sources/p5_web_help_work
  #export LINUX_BASE_DIR=/media/ssd/git_hm_sources/p5_linux_kernel_work
else
  shine_dir=/media/ssd/git_hm_sources/p5_smart_shine
  export SHINE_SHARED_DIR=/media/ssd/git_hm_sources/p5_hirschmann_shared
  export WEB_HELP_DIR=/media/ssd/git_hm_sources/p5_web_help
  export LINUX_BASE_DIR=/media/ssd/git_hm_sources/p5_linux_kernel
fi


export CROSS_COMPILE=powerpc-603e-linux-gnu-
export TOOLCHAIN_BASE_DIR=/opt/toolchain/OSELAS.Toolchain-2016.06.1/powerpc-603e-linux-gnu/gcc-5.4.0-glibc-2.23-binutils-2.26-kernel-4.6-sanitized
export KFLAG_INCLD=${TOOLCHAIN_BASE_DIR}/lib/gcc/powerpc-603e-linux-gnu/5.4.0/include
export PATH=${TOOLCHAIN_BASE_DIR}/bin:$PATH
export TOOL=

export TMPDIR=/tmp/

cd ${shine_dir}

bash


