#!/bin/bash

# Add your csp application here

\printf '<Location /csp>\n   CSP On \n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf

# \printf '<Location /api>\n   CSP On \n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf
# \printf '<Location /isc>\n   CSP On \n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf
# \printf '<Location /swagger-ui>\n   CSP On \n   CSPFileTypes *\n   SetHandler csp-handler-sa\n</Location>\n' >> /etc/apache2/mods-enabled/CSP.conf

ln -fs /usr/share/zoneinfo/Europe/Brussels /etc/localtime

# apt-get update && apt-get install -y links iputils-ping software-properties-common
# apt-get update && apt-get install -y iputils-ping software-properties-common

rm -f /opt/webgateway/bin/CSP.ini
mv /webgateway-config-files/CSP.ini /opt/webgateway/bin/CSP.ini

chown root /webgateway-config-files/apache_webgateway.crt /webgateway-config-files/apache_webgateway.key
chgrp root /webgateway-config-files/apache_webgateway.crt
chgrp www-data /webgateway-config-files/apache_webgateway.key
chmod 640 /webgateway-config-files/apache_webgateway.key
mkdir /etc/apache2/certificate

mv /webgateway-config-files/apache_webgateway.* /etc/apache2/certificate/

a2enmod rewrite && a2enmod ssl && a2enmod socache_shmcb && a2enmod headers