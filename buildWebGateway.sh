#!/bin/bash

# Add your csp application here or use the environment variable IRIS_WEBAPPS in docker-compose file

# \printf '<Location /csp>\n   CSP On \n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf
# \printf '<Location /api>\n   CSP On \n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf
# \printf '<Location /isc>\n   CSP On \n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf
# \printf '<Location /swagger-ui>\n   CSP On \n   CSPFileTypes *\n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf

# To adapt with your localtime
ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime

# apt-get update && apt-get install -y links iputils-ping software-properties-common
# apt-get update && apt-get install -y iputils-ping software-properties-common

rm -f /opt/webgateway/bin/CSP.ini
mv /webgateway-config-files/CSP.ini /opt/webgateway/bin/CSP.ini

a2enmod rewrite && a2enmod ssl && a2enmod socache_shmcb && a2enmod headers