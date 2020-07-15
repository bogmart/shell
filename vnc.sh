#/bin/sh

sudo killall x11vnc

x11vnc -repeat -nowf -ncache_cr -skip_lockkeys -clear_all -nevershared -dontdisconnect --display :0

if [ $? -ne 0 ]
  then
    sudo x11vnc -repeat -nowf -ncache_cr -skip_lockkeys -clear_all -nevershared -dontdisconnect --display :0 -auth /var/lib/lightdm/.Xauthority
  fi


# HELP
#
# Xauthority:
#   gdm
#     /run/user/117/gdm/Xauthority     <== ps wwwwaux | grep auth
#   lightdm
#     /var/lib/lightdm/.Xauthority
#
#
# -repeat == key press repeat 
#    https://ubuntuforums.org/showthread.php?t=1344610
#
# -skip_lockkeys  -clear_all   == enable "num lock" (numeric keys)  BUT  "undo" { ctrl z} is not functional when "caps lock"
# -nomodtweak                  == enable "num lock" (numeric keys)  BUT  "<" key is not functional
#
# -nevershared -dontdisconnect == refuse new connection
#
#
# restart GUI
#   sudo systemctl restart lightdm


