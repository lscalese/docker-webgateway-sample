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
sudo ./gen-certificates.sh
cd ..
```

## Build tls-ssl-webgateway

```
docker build --no-cache -t tls-ssl-webgateway .
```

## Starting containers

By default port 80 and 443 are mapped in `docker-compose.yml`, adapt with anothers ports if they are already used on your system.  

```
$ docker-compose up
```

## How to Test it

Wait the containers are ready.  

Open your browser and open the management portal [https://localhost/csp/sys/utilhome.csp](https://localhost/csp/sys/utilhome.csp)  
Also http call will be redirected to https.  

If you use a self signed certificate, the browser show alert.  Accept and continue...

Congrats, you have a Webgateway using https and tls\ssl to communicate with IRIS.  