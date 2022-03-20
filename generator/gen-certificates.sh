#!/bin/bash

# clean previous execution.
rm -vfr ./certificates ../certificates

mkdir -v ./certificates
chmod 777 ./certificates

docker run \
 --entrypoint /external/irisrun.sh \
 --name cert_generator \
 --volume $(pwd):/external \
 intersystemsdc/iris-community:latest \
 "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=webgateway" "webgateway_client" \
 "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=webgateway" "apache_webgateway" \
 "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=iris" "iris_server"

docker container rm cert_generator

# change permissions

chown -v irisowner ./certificates/*_server.cer ./certificates/*_server.key
chgrp -v irisowner ./certificates/*_server.cer ./certificates/*_server.key
chmod -v 644 ./certificates/*_server.cer

# chmod for private key should be 600, but we have permissions denied with IRIS
# Maybe irisowner is not the good owner for these files. to analyse...
chmod -v 640 ./certificates/*.key
chgrp -v irisuser ./certificates/*_server.key

chown -v www-data ./certificates/apache_webgateway.cer
chgrp -v www-data ./certificates/apache_webgateway.key
chmod -v 644 ./certificates/apache_*.cer
chmod -v 600 ./certificates/apache_webgateway.key

chown -v root ./certificates/webgateway_client.cer ./certificates/webgateway_client.key
chgrp -v www-data ./certificates/webgateway_client.cer ./certificates/webgateway_client.key
chmod -v 640 ./certificates/webgateway_*.cer 

mv -v ./certificates ../certificates
