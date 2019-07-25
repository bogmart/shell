#!/bin/bash

#export USER=uxs11111
#export USERNAME=uxs11111

wind_linux=/media/SSD/WindRiver32_linux
shine_dir=/media/SSD/bogmart_workbench/p5_smart_shine

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${wind_linux}/workbench-3.3/foundation/x86-linux2/lib:${wind_linux}/lmapi-5.0/x86-linux2/lib

export TMPDIR=/media/tmpfs/


${wind_linux}/workbench-3.3/foundation/x86-linux2/bin/wtxregd restart

cd ${shine_dir}

${wind_linux}/wrenv.linux -p vxworks-6.9 

