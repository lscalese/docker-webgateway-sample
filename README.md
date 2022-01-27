## docker-webgateway-sample

This is a sample to run an Intersystems Wegateway using https and tls\ssl configuration for the communication with an IRIS instance.  



## Installation 

Clone/git pull the repo into any local directory

```
$ git clone https://github.com/lscalese/docker-webgateway-sample.git
```

## Build tls-ssl-webgateway

If you have already a certificate, copy it (and its private key) in `./webgateway-config-files/` directory.  
Files must be named :  

 * apache_webgateway.crt
 * apache_webgateway.key

If you don't have certifcate, we can generate a self-signed.  

Open the terminal in this directory and run: 

```bash
cd ./webgateway-config-files
openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out ./apache_webgateway.crt -keyout apache_webgateway.key -subj "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=webgateway"
```

You can adapt the subject argument to your need:  

 * **C** : Country code
 * **ST** : State
 * **L** : Location
 * **O** : Organization
 * **OU** : Organization Unit
 * **CN** : Common name (basicaly the domain name or the hostname)



```
$ docker-compose build --no-cache -t tls-ssl-webgateway .
```

## Starting containers

By default port 80 and 443 are mapped in `docker-compose.yml`, adapt with anothers ports if they are already used on your system.  

```
$ docker-compose up
```

## How to Test it

Wait the containers are ready.  

you should see these messages when it's ready:  

```
tls-ssl-webgateway | [INFO] ...httpd done
tls-ssl-webgateway | [INFO] Starting rsyslogd...
tls-ssl-webgateway | [INFO] ...rsyslogd done
tls-ssl-webgateway | [INFO] Tailing logs...
tls-ssl-webgateway | ==> /opt/webgateway/bin/CSP.log <==
tls-ssl-webgateway | >>> Time: Thu Jan 27 21:12:06 2022; RT Build: 2101.1776 (linux/apapi); Log-Level: 0; Gateway-PID: 132; Gateway-TID: 139642102819776
tls-ssl-webgateway |     Initialization
tls-ssl-webgateway |     The Web Gateway module '/opt/webgateway/bin/CSPa24.so' is loaded (IPv6 Enabled; MAX_CONNECTIONS=1024; MAX_SERVERS=9; MAX_APPLICATIONS=280; MAX_RESPONSE_BUFFER_SIZE=128000; Connection_Allocation=First Free; Nagle_Algorithm=Disabled; SHM=OS; IPC=DS)
tls-ssl-webgateway | >>> Time: Thu Jan 27 21:12:06 2022; RT Build: 2101.1776 (linux/apapi); Log-Level: 0; Gateway-PID: 133; Gateway-TID: 139642102819776
tls-ssl-webgateway |     Initialization: Apache Parent Process
tls-ssl-webgateway |     Global Configuration Block Initialized: PID=133; SHMID=11; SHMType=0;
tls-ssl-webgateway | 
tls-ssl-webgateway | ==> /var/log/apache2/access.log <==
tls-ssl-webgateway | 
tls-ssl-webgateway | ==> /var/log/apache2/error.log <==
tls-ssl-webgateway | [Thu Jan 27 21:12:06.698890 2022] [ssl:warn] [pid 132:tid 139642102819776] AH01906: webgateway:443:0 server certificate is a CA certificate (BasicConstraints: CA == TRUE !?)
tls-ssl-webgateway | [Thu Jan 27 21:12:06.726266 2022] [ssl:warn] [pid 133:tid 139642102819776] AH01906: webgateway:443:0 server certificate is a CA certificate (BasicConstraints: CA == TRUE !?)
```

Open your browser and open the management portal [https://localhost/csp/sys/utilhome.csp](https://localhost/csp/sys/utilhome.csp)  
Also http call will be redirected to https.  

If you use a self signed certificate, the browser show alert.  Accept and continue...

Congrats, you have a Webgateway using https and tls\ssl to communicate with IRIS.  