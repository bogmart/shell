#/bin/sh

DBG_LOG_PATH=/media/data/logs/gdb_logs
DBG_LOG_FILE="dbg_brs_$(date +"%Y-%m-%d_%H-%M").txt"
export DBG_LOG_FULL=${DBG_LOG_PATH}/${DBG_LOG_FILE}

export DBG_GIT_BASE_DIR=/media/ssd/git_hm_sources
export DBG_GIT_SHINE_DIR_NAME=p5_smart_shine
export DBG_GIT_SHARED_DIR_NAME=p5_hirschmann_shared
export DBG_GIT_LINUX_DIR_NAME=p5_linux_kernel

export DBG_IMG_SUBDIR=brs2s
export DBG_LEVEL_SUBDIR=DEBUG_6

gdb_script=~/scripts/gdb-script

#echo "argument(s) supplied: " $1
if [ ! -z "$1" ] 
then
 export DBG_REMOTE=1
fi

echo "gdb_script: " ${gdb_script}

cd ${DBG_GIT_BASE_DIR}
gdbarm  ${DBG_GIT_SHINE_DIR_NAME}/target/am335_l/avenger/${DBG_LEVEL_SUBDIR}/ipl/switchdrvr -x ${gdb_script}

