#!/bin/bash

#
# sample start stop script
#

# Package
DNAME="PlexConnect"
PNAME="PlexConnect_daemon"

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"

# Others
INSTALL_DIR=${DIR}
PYTHON="python"
PROGRAM="./${PNAME}.py"
PID_FILE="/var/${PNAME}.pid"
LOG_FILE="${DIR}/PlexConnect.log"
STG_FILE="${DIR}/Settings.cfg"

start_daemon ()
{
    cd "${INSTALL_DIR}"
    ${PYTHON} ${PROGRAM} --pidfile ${PID_FILE}
}

stop_daemon ()
{
    kill `cat ${PID_FILE}`
    wait_for_status 1 20 || kill -9 `cat ${PID_FILE}`
    rm -f ${PID_FILE}
}

daemon_status ()
{
    if [ -f ${PID_FILE} ] && kill -0 `cat ${PID_FILE}` > /dev/null 2>&1; then
        return
    fi
    rm -f ${PID_FILE}
    return 1
}

wait_for_status ()
{
    counter=$2
    while [ ${counter} -gt 0 ]; do
        daemon_status
        [ $? -eq $1 ] && return
        let counter=counter-1
        sleep 1
    done
    return 1
}


case $1 in
    start)
        if daemon_status; then
            echo ${DNAME} is already running
        else
            echo Starting ${DNAME} ...
            start_daemon
        fi
        ;;
    stop)
        if daemon_status; then
            echo Stopping ${DNAME} ...
            stop_daemon
        else
            echo ${DNAME} is not running
        fi
        ;;
    status)
        if [ -f "${LOG_FILE}" ]; then
            chmod 775 "${LOG_FILE}"
        fi
        if [ -f "${STG_FILE}" ]; then
            chmod 775 "${STG_FILE}"
        fi
        if daemon_status; then
            echo 1
            exit 0
        else
            echo 0
            exit 1
        fi
        ;;
    *)
        exit 1
        ;;
esac