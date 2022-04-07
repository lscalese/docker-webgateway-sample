## docker-webgateway-sample

This is a sample to run an Intersystems Wegateway using https and tls\ssl configuration for the communication with an IRIS instance.  



## Installation 

Clone/git pull the repo into any local directory

```bash
git clone https://github.com/lscalese/docker-webgateway-sample.git
cd ./docker-webgateway-sample
```

## Prepare your system 

```bash
sudo useradd --uid 51773 --user-group irisowner
sudo groupmod --gid 51773 irisowner
sudo useradd –user-group www-data
```

## Generate certificates

```
docker pull intersystemsdc/iris-community:latest
cd ./generator
# sudo is needed due chown, chgrp, chmod ...
sudo ./gen-certificates.sh
# move certificate for apache webserver to the home directory.  
mkdir -vp ~/webgateway-apache-certificates
mv -vn ./certificates/apache_webgateway.cer ~/webgateway-apache-certificates/apache_webgateway.cer
mv -vn ./certificates/apache_webgateway.key ~/webgateway-apache-certificates/apache_webgateway.key
cd ..
```

Generated certficates will be in `./certificates` directory for IRIS instances and webgateway component.  
The certificate and the private for apache webserver will be in your home directory `~/webgateway-apache-certificates`.  
If files alread exist, they won't be overrided.  

Using a new generated a certificate for each try on the webserver could cause an error `Certificate contains the same serial number as another certificate`.  
See troubleshoot section to fix it if you encounter this problem.  

Certficates files overview : 

| File | Container | Description |
|--- |--- |--- |
| ~/webgateway-apache-certificates/apache_webgateway.cer | webgateway | Certificate for apache webserver |
| ~/webgateway-apache-certificates/apache_webgateway.key | webgateway | Related private key |
| ./certificates/webgateway_client.cer | webgateway | Certificate to encrypt communication between webgateway and IRIS |
| ./certificates/webgateway_client.key | webgateway | Related private key |
| ./certificates/CA_Server.cer | webgateway,iris | Authority server certificate|
| ./certificates/iris_server.cer | iris | Certificate for IRIS instance (used for mirror and wegateway communication encryption) |
| ./certificates/iris_server.key | iris | Related private key |

## Build tls-ssl-webgateway

```
sudo docker-compose build --no-cache
```

Or without sudo: 

```
docker build --no-cache -t tls-ssl-webgateway .
```

## Starting containers

Before starting containers, edit the `docker-compose.yml` file :  

 1. `SYSTEM_MANAGER` must be set with the IP authorized to have an access to **WebGateway Management** https://localhost/csp/bin/Systems/Module.cxw  
    Basically, it's your IP address (It could be a comma separated list).  
 2. `IRIS_WEBAPPS` must be set with the list of your csp applications.  The list is separated by space, ex : `IRIS_WEBAPPS=/csp/sys /swagger-ui`.  
    By default only `/csp/sys` is exposed.  
 3. Port 80 and 443 are mapped, adapt with anothers ports if they are already used on your system.  
 

```
$ docker-compose up
```

## How to Test it

Wait the containers are ready.  

Open your browser and open the management portal [https://localhost/csp/sys/utilhome.csp](https://localhost/csp/sys/utilhome.csp)  
Also http call will be redirected to https.  

If you use a self signed certificate, the browser show alert.  Accept and continue...

Congrats, you have a Webgateway using https and tls\ssl to communicate with IRIS.  


# Troubleshoot

## Certificate contains the same serial number as another certificate

With firefox It could happen when we generate new Authority Certificate

Delete cert9.db file and restart : 
~/.mozilla/firefox/xktesjjl.default-release/cert9.db

