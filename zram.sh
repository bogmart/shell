#!/bin/bash

#This is deprecated since I installed zswap
#https://ubuntu-mate.community/t/enable-zswap-to-increase-performance/11302
#https://wiki.archlinux.org/index.php/zswap


#lz4 install
#sudo apt-get install liblz4-tool
#https://catchchallenger.first-world.info/wiki/Quick_Benchmark:_Gzip_vs_Bzip2_vs_LZMA_vs_XZ_vs_LZ4_vs_LZO
#https://www.systutorials.com/docs/linux/man/8-zramctl/

CPUS=`nproc`
swapHDD=$(sudo blkid | grep "TYPE=\"swap\" PARTUUID=" | cut -f1 -d:)


#nu e nevoie sa inchid swap-ul pe HDD deoarece zram-ul este facut cu prioritate ("-p 10") deci este folosit primul; daca se umple atunci trece pe HDD
#swapoff /dev/sdb5

case "$1" in
  start)
    echo "${swapHDD}"
    sudo swapon ${swapHDD} -p 0

    FRACTION=75
    MEMORY=`perl -ne'/^MemTotal:\s+(\d+)/ && print $1*1024;' < /proc/meminfo`
    SIZE=$(( MEMORY * FRACTION / 100 / CPUS ))

    param=`modinfo zram|grep num_devices|cut -f2 -d:|tr -d ' '`
    sudo modprobe zram $param=${CPUS}
    for n in `seq $CPUS`; do
      devZram=$(sudo zramctl --find --size $SIZE -a lz4)
      sudo mkswap ${devZram}
      sudo swapon ${devZram} -p 10
    done
  ;;

  stop)
    echo "${swapHDD}"
    sudo swapoff ${swapHDD}
    for swapRAM in "$(sudo zramctl -o NAME -n)"
    do
      echo "${swapRAM}"
      sudo swapoff ${swapRAM}
      sudo zramctl --reset ${swapRAM}
    done
  ;;

  status)
    swapon -s
    echo
    zramctl
    ;;

  *)
    echo "This is deprecated since I installed zswap!"
    echo ""
    echo "Usage: $NAME {start|stop|status}" >&2
    exit 2
  ;;
esac



