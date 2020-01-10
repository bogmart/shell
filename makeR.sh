#/bin/bash


timeStats='/usr/bin/time -f "\n
				real time:\t\t\t%E\n
				CPU-secs (kernel):\t\t%S\n
				CPU-secs (user):\t\t%U\n
				ctxt switches (io):\t\t%w\n
				ctxt switches (time slice):\t%c\n
				page faults (major):\t\t%F\n
				page faults (minnor):\t\t%R\n
				filesystem in:\t\t\t%I\n
				filesystem out:\t\t%O\n
				signals:\t\t\t%k\n
			     "
	  '
#timeStats='/usr/bin/time -p'
#timeStats='time'


hw=ees
target=
targetDefault=BIN
debug=2
speed=8
webBuild=1
logConsole=2
versionName=B.Mar
optionsUnknown=

log_output_dir=/media/data/versiuni/bogmart_builds/build_logs
log_output_latest=${log_output_dir}/build_latest.txt

filterInclude=/tmp/makeR_filterInclude.txt
echo ".*error:.*"                    > ${filterInclude}
echo ".*ERROR: .*"                   >> ${filterInclude}
echo ".*make.*Error.*"               >> ${filterInclude}
echo ".*undefined reference to.*"    >> ${filterInclude}
echo ".*unknown type:.*"             >> ${filterInclude}
echo ".*RuntimeException.*"          >> ${filterInclude}
echo ".*Caused by:.*"                >> ${filterInclude}
echo ".*MIBLoader.*"                 >> ${filterInclude}
echo ".*MibDefGenerator.*"           >> ${filterInclude}
echo ".*syntax error.*"              >> ${filterInclude}
echo ".*multiple definition of.*"    >> ${filterInclude}
echo ".*first defined here.*"        >> ${filterInclude}
echo ".*First name: .*"              >> ${filterInclude}
echo ".*No rule to make target.*"    >> ${filterInclude}
#shell
echo ".*not found.*"                 >> ${filterInclude}
#echo ".*last token read.*"           >> ${filterInclude}

filterExclude="(ignored)"

print_usage()
{
      echo "Usage: $(basename $0)  [hw]         [target]    [options]"
      echo "       $(basename $0)"
      echo "       $(basename $0)   TARGET=msp2a"
      echo "       $(basename $0)   TARGET=rsp    HC         DEBUG=0 SPEED=1"
      echo "       ( default: TARGET=${hw}    ${targetDefault}        DEBUG=${debug} LOG_CONSOLE=${logConsole} SPEED=${speed} VERSION=${versionName} WEB_BUILD=${webBuild} )"
      echo ""
      echo "Note:"
      echo "      Bitwise debug flags:  1: -DDEBUG"
      echo "                            2: -g -ggdb"
      echo "                            4: -O0"
      echo "                            8: no -Werror"
      echo "                            16: cUnit framework included"
      echo ""
      echo "      SHINE_SHARED_DIR e.g. SHINE_SHARED_DIR=/media/SSD/bogmart_workbench/p5_hirschmann_shared_master"
}

#https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
for i in "$@"
do
  case $i in
    TARGET=*)
      hw="${i#*=}"
      shift # past argument=value
      ;;
    DEBUG=*)
      debug="${i#*=}"
      shift # past argument=value
      ;;
    LOG_CONSOLE=*)
      logConsole="${i#*=}"
      shift # past argument=value
      ;;
    SPEED=*)
      speed="${i#*=}"
      shift # past argument=value
      ;;
    VERSION=*)
      versionName="${i#*=}"
      shift # past argument=value
      ;;
    WEB_BUILD=*)
      webBuild="${i#*=}"
      shift # past argument=value
      ;;
    *=*)
      optionsUnknown="${optionsUnknown} ${i}"
      shift # past argument=value
      ;;
    -h|--h|-help|--help|/?)
      print_usage
      exit 2
      ;;
    *)
      target="${target} ${i}"
      shift # past argument
      ;;
esac
done


output_file=${log_output_dir}/build_${hw}_dbg_${debug}_$(date +"%Y.%m.%d-%H.%M.%S").txt


if [ -z "${target}" ]
then
  target=${targetDefault}
fi

touch  ${output_file} 
unlink ${log_output_latest}
ln -s  ${output_file}   ${log_output_latest}


echo -e make TARGET=${hw} ${target} DEBUG=${debug} LOG_CONSOLE=${logConsole} SPEED=${speed} VERSION=${versionName} \
               WEB_BUILD=${webBuild} ${optionsUnknown} > ${output_file} \\n

(eval ${timeStats} nice  make TARGET=${hw} ${target} DEBUG=${debug} LOG_CONSOLE=${logConsole} SPEED=${speed} VERSION=${versionName} \
               WEB_BUILD=${webBuild} ${optionsUnknown} 2>&1) 2>&1 | tee -a ${output_file}

makeExitCode=${PIPESTATUS[0]}

if [ "${makeExitCode}" -ne "0" ]
then
   echo ""
   echo ${log_output_latest}
   cat ${output_file} | parallel -j ${speed} --k --round --pipe  grep --color=always -f "${filterInclude}" | grep -v "${filterExclude}"
fi

exit ${makeExitCode}



