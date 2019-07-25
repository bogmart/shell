#/bin/sh

gdb_script=~/scripts/script-gdb

#echo "argument(s) supplied: " $1
if [ ! -z "$1" ] 
then
 gdb_script=~/scripts/script-gdb-remote
fi

#echo "gdb_script: " $gdb_script

cd /media/SSD/bogmart_workbench
gdbarm  p5_smart_shine/target/am335_l/avenger/DEBUG_6/ipl/switchdrvr -x $gdb_script

