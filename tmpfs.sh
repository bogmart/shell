#/bin/sh

tmpFs=/media/tmpfs
homeVersions=/home/versiuni
smartShine=/media/SSD/bogmart_workbench/p5_smart_shine
buildLogs=${tmpFs}/build_logs


sudo mkdir -p ${tmpFs}
sudo mount -t tmpfs -o size=40G tmpfs ${tmpFs}/

mkdir -p ${tmpFs}/target


if [[ ! -e ${smartShine}/target && -L ${smartShine}/target ]]
then
  # echo "symbolic link isn't valid"
  unlink ${smartShine}/target
fi
if [ ! -L ${smartShine}/target ]
then
  # echo "symbolic link doesn't exist"
  ln -s ${tmpFs}/target  ${smartShine}/target
fi


#allow access to a symlink when VSFTPD is chrooted on the home directory
sudo mkdir -p ${homeVersions}
sudo mkdir -p ${homeVersions}/target

#required if the RamDrive is used as "target" for builds
#sudo mount --bind ${tmpFs}/target/ ${homeVersions}/target


mkdir -p ${buildLogs}
