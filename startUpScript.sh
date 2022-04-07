#!/bin/bash

CSPCONFFILEDIR=${ISC_DATA_DIRECTORY:-/etc/apache2/mods-enabled}
CSPINIFILEDIR=${ISC_DATA_DIRECTORY:-/opt/webgateway/bin}

CSPINIFILE=${CSPINIFILEDIR}/CSP.ini
CSPCONFFILE=${CSPCONFFILEDIR}/CSP.conf

if [ ! "$IRIS_HOST" = "" ]
then
    sed -i '/Ip_Address=/c\Ip_Address='$IRIS_HOST $CSPINIFILE
fi

if [ ! "$IRIS_PORT" = "" ]
then
    sed -i '/TCP_Port=/c\TCP_Port='$IRIS_PORT $CSPINIFILE
fi

if [ ! "$SYSTEM_MANAGER" = "" ]
then
    sed -i '/System_Manager=/c\System_Manager='$SYSTEM_MANAGER
fi

for webapp in $IRIS_WEBAPPS
do
    
    if ! grep -q "<Location $webapp>" "$CSPCONFFILE"
    then
        echo "Add webapp $webapp to $CSPCONFFILE"
        \printf '<Location '$webapp'>\n   CSP On \n   CSPFileTypes *\n   SetHandler csp-handler-sa\n</Location>\n' >> $CSPCONFFILE
    else
        echo "Webapp $webapp already exist in $CSPCONFFILE"
    fi
done

mv /webgateway-config-files/000-default.conf /etc/apache2/sites-enabled/000-default.conf

/startWebGateway