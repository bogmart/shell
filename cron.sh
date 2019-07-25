#echo "=== Clean up v99999 folder ==="
#echo "(Deleting all folders that are older than 20 days)"
#/usr/bin/find /raid/smb/K-Stufen/PlattformV/v99999 -mindepth 1 -maxdepth 1 -type d -mtime +20 -exec echo {} \; -exec /usr/bin/rm -r {} \;

HM_BASE_DIR="/raid/smb/K-Stufen/PlattformV"

cd $HM_BASE_DIR

for i in $( ls -d -1 -q v07* v99999 ); do

    cd $i
    if [ $? -ne 0 ]; then
        echo "Could not cd, ignoring directory ($i)" >&2
        continue
    fi
    echo ""
    echo -n "=== Directory: "
    pwd

    for j in $( echo "CMT NTLY" ); do
        ls -d -1 -t -q $j* 2> /dev/null | tail -n +11 | xargs -d '\n' -r rm -rfv
        if [ $? -ne 0 ]; then
            echo "Problem with xargs: $?" >&2
        fi
    done

    cd $HM_BASE_DIR

done
