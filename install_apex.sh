#!/bin/bash

cd ${APEX_HOME}

echo Test database
logon="${SYS_USER}/${SYS_PASSWORD}@//${DB_HOSTNAME}:${DB_PORT}/${DB_SERVICE} as SYSDBA"
echo "SELECT * FROM DUAL;
exit"| sql -L $logon

APEX_TABLESPACE="SYSAUX"
APEX_TABLESPACE_FILES="SYSAUX"
APEX_TABLESPACE_TEMP="TEMP"
APEX_IMAGE_PREFIX="/i/"
APEX_PUBLIC_USER_PW="${ORDS_PW}"

echo "@apex_service_install_helper.sql"
sql -L $logon @apex_service_install_helper.sql ${APEX_TABLESPACE} ${APEX_TABLESPACE_FILES} ${APEX_TABLESPACE_TEMP} ${APEX_IMAGE_PREFIX} ${APEX_PUBLIC_USER_PW}

