#!/bin/bash

#exit on error
set -euo pipefail
trap 'exit 130' INT


# substitute the param file with current environment variables
cat /ords_params.properties.tmpl | envsubst > $ORDS_PARAMS

echo test database
logon="${SYS_USER}/${SYS_PASSWORD}@//${DB_HOSTNAME}:${DB_PORT}/${DB_SERVICE} as SYSDBA"
echo "SELECT * FROM DUAL;
exit"| sql -L $logon

# run ORDS simple install with the generated param file 
echo simple install ORDS
java -jar $ORDS_HOME/ords.war install simple --parameterFile $ORDS_PARAMS 

echo  Start tomcat 
catalina.sh run