#!/bin/sh

RSA_KEY_NUMBITS="2048"
DAYS="365"

GenRootCertificate() {
    local ROOT_SUBJ=$1
    local CERT_FNAME=$2
    
    echo "Generating root certificate"

    if [ ! -f "$CERT_FNAME.key" ]
    then
    # generate root certificate
    
    openssl genrsa \
        -out "$CERT_FNAME.key" \
        "$RSA_KEY_NUMBITS"

    openssl req \
        -new \
        -key "$CERT_FNAME.key" \
        -out "$CERT_FNAME.csr" \
        -subj "$ROOT_SUBJ"

    openssl req \
        -x509 \
        -key "$CERT_FNAME.key" \
        -in "$CERT_FNAME.csr" \
        -out "$CERT_FNAME.cer" \
        -days "$DAYS"

    chown -v irisowner $CERT_FNAME.cer $CERT_FNAME.key
    chgrp -v irisowner $CERT_FNAME.cer
    chgrp -v irisuser $CERT_FNAME.key
    chmod -v 644 $CERT_FNAME.cer

    else
    echo "ENTRYPOINT: ./certificates/CA_Server.key already exists"
    fi

}

GenCertificate() {
    local PUBLIC_SUBJ=$1
    local CERT_FNAME=$2
    local CERT_ROOT=${3:-./certificates/CA_server.cer}

    
    if [ ! -f "$CERT_FNAME.cer" ]
    then
    # generate public rsa key
    openssl genrsa \
        -out "$CERT_FNAME.key" \
        "$RSA_KEY_NUMBITS"
    else
    echo "ENTRYPOINT: $CERT_FNAME.cer already exists"
    return
    fi

    if [ ! -f "$CERT_FNAME.cer" ]
    then
    # generate public certificate
    
    openssl req \
        -new \
        -key "$CERT_FNAME.key" \
        -out "$CERT_FNAME.csr" \
        -subj "$PUBLIC_SUBJ"

    openssl x509 \
        -req \
        -in "$CERT_FNAME.csr" \
        -CA "$CERT_ROOT.cer" \
        -CAkey "$CERT_ROOT.key" \
        -out "$CERT_FNAME.cer" \
        -CAcreateserial \
        -days "$DAYS"
    
    cat $CERT_ROOT.cer >> "$CERT_FNAME.cer"
    else
    echo "ENTRYPOINT: $CERT_FNAME.cer already exists"
    fi
}

rm -vfr certificates

mkdir -p ./certificates
GenRootCertificate "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=testroot" "./certificates/CA_Server"
rm -vfr ./certificates/CA_Server.csr

# GenCertificate Arguments : 
#  1. subject without CN
#  2. CN
#  3. Certificate filename
#  4. Root Certificate filename

# Generate webgateway client certificate.
GenCertificate "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=webgateway" "./certificates/webgateway_client" "./certificates/CA_Server"
rm -vfr ./certificates/webgateway_client.csr
chown root ./certificates/webgateway_client.key ./certificates/webgateway_client.cer
chgrp www-data ./certificates/webgateway_client.key ./certificates/webgateway_client.cer
chmod 644 ./certificates/webgateway_client.key ./certificates/webgateway_client.cer

# Generate IRIS server certificate
GenCertificate "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=iris" "./certificates/iris_server" "./certificates/CA_Server"
rm -vfr ./certificates/iris_server.csr
chown irisowner ./certificates/iris_server.key ./certificates/iris_server.cer
chgrp irisowner ./certificates/iris_server.cer 
chgrp irisuser ./certificates/iris_server.key
chmod 644 ./certificates/iris_server.cer
chmod 640 ./certificates/iris_server.key

# Generate Apache Web Server Certificate
USER_HOME=$(getent passwd ${SUDO_USER:-$USER} | cut -d: -f6)
mkdir -p $USER_HOME/webgateway-apache-certificates
CRTFNAME=$USER_HOME/webgateway-apache-certificates/apache_webgateway

GenCertificate "/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=webgateway" "$CRTFNAME" "./certificates/CA_Server"
rm -vfr $CRTFNAME.csr
chown www-data $CRTFNAME.cer
chown irisowner $CRTFNAME.key
chgrp irisowner $CRTFNAME.cer
chgrp www-data $CRTFNAME.key
chmod 644 $CRTFNAME.cer
chmod 600 $CRTFNAME.key
