#!/bin/bash

DIRTMPCERT=./certificates
VOLAPACHE=../volume-apache-test
VOLIRIS=../volume-iris-test

# clean previous execution.
rm -vfr ${DIRTMPCERT} ${VOLIRIS} ${VOLAPACHE}

mkdir ${DIRTMPCERT} ${VOLIRIS} ${VOLAPACHE}
chmod 777 ${DIRTMPCERT}/

docker run \
 --entrypoint /external/irisrun.sh \
 --name cert_generator \
 --publish 1972:1972 --publish 52773:52773 \
 --volume $(pwd):/external \
 intersystemsdc/iris-community:latest

docker container rm cert_generator

# chmod to avoid a permission denied for the copy
chmod 777 ${DIRTMPCERT}/*

cp ${DIRTMPCERT}/CA_Server.cer ${VOLIRIS}/CA_Server.cer
cp ${DIRTMPCERT}/CA_Server.cer ${VOLAPACHE}/CA_Server.cer

cp ${DIRTMPCERT}/iris_server.cer ${VOLIRIS}/iris_server.cer
cp ${DIRTMPCERT}/iris_server.key ${VOLIRIS}/iris_server.key


cp ${DIRTMPCERT}/apache_webgateway.cer ${VOLAPACHE}/apache_webgateway.cer
cp ${DIRTMPCERT}/apache_webgateway.key ${VOLAPACHE}/apache_webgateway.key
cp ${DIRTMPCERT}/webgateway_client.cer ${VOLAPACHE}/webgateway_client.cer
cp ${DIRTMPCERT}/webgateway_client.key ${VOLAPACHE}/webgateway_client.key

# change permissions

chown irisowner ${VOLIRIS}/*
chgrp irisowner ${VOLIRIS}/*
chmod 640 ${VOLIRIS}/CA_Server.cer ${VOLIRIS}/iris_server.cer
chmod 600 ${VOLIRIS}/iris_server.key

chown www-data ${VOLAPACHE}/*.key
chgrp www-data ${VOLAPACHE}/*.key
chmod 600 ${VOLAPACHE}/*.key
chown root ${VOLAPACHE}/*.cer
chgrp root ${VOLAPACHE}/*.cer
chmod 644 ${VOLAPACHE}/*.cer

