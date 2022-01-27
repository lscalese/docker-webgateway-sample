#!/bin/bash

# Certficate filename (use by the webservice)
WSCERTFILENAME=${CERTIFICATE_FILENAME:-"webgateway_client"}

# PKI Server IP:PORT
PKISRV=${PKI_SERVER:-localhost\:81}

# Hostname ... -_-
MYHOSTNAME=${HOST_NAME:-$(cat /proc/sys/kernel/hostname)}

# Certificate Subject
CSRSUBJECT=${CERTIFICATE_SUBJECT:-/C=BE/ST=Wallonia/L=Namur/O=Community/OU=IT/CN=webgateway}

# Ho My, I hate this.
CSRSUBJESC=$(${CSRSUBJECT//\//\\\\\/})

# CONTACT INFO
#
CONTACTNAME=${CONTACT_NAME:-ContactPerson}

# 
CONTACTPHONE=${CONTACT_PHONE:-ContactPhone}

#
CONTACTEMAIL=${CONTACT_NAME:-ContactMail}

# File contains the SOAP body template.
# A part of this file must be remplaced.
TEMPLATEREQUESTBODY=template-submitcsr.xml

# Output file contains the SOAP body for submit a csr.  
# This the result of the template with values replaced.
REQUESTBODYCSR=requestbody-submitcsr.xml

# Request certificate csr file
CSRFILE="$WSCERTFILENAME.csr"

# Private key filename
KEYFILE="$WSCERTFILENAME.key"

CERTFILENAME="$WSCERTFILENAME.cer"

DFLTRESPONSEFILE="PKI.CAServer.cls"

PrepareRequestBodyCSR() {
    # Insert the csr into the xml by replacing the place older text TheRequestCertificate.
    sed "s/TheRequestCertificate/$(sed -e 's/[\&/]/\\&/g' -e 's/$/\\n/' $CSRFILE | tr -d '\n')/" $TEMPLATEREQUESTBODY > $REQUESTBODYCSR
    sed -i "s/hostname/$MYHOSTNAME/g" $REQUESTBODYCSR
    sed -i "s/CertificateFileName/$WSCERTFILENAME/g" $REQUESTBODYCSR
    sed -i "s/ContactNameToReplace/$CONTACTNAME/g" $REQUESTBODYCSR
    sed -i "s/PhoneToReplace/$CONTACTPHONE/g" $REQUESTBODYCSR
    sed -i "s/EmailToReplace/$CONTACTEMAIL/g" $REQUESTBODYCSR
    sed -i "s/CsrSubject/$CSRSUBJESC/g" $REQUESTBODYCSR
    return 1
}

# Send the request to PKI Server.
SubmitCSRRequest() {
    local success=0

    wget --no-check-certificate --quiet \
        --method POST \
        --timeout=15 \
        --header 'Content-Type: text/xml; charset=utf-8' \
        --header 'SOAPAction: http://pki.intersystems.com/PKI.CAServer.SubmitCSR' \
        --header 'Cookie: CSPSESSIONID-SP-81-UP-isc-pki-=000000000000B8x0QrAT4PN6gCSV2SDi4i5u1s81uzT4Uvxkxz; CSPWSERVERID=hzYoK7sO' \
        --body-file requestbody-submitcsr.xml \
        "http://$PKISRV/isc/pki/PKI.CAServer.cls"

    # Check if request is successfully submitted.
    if grep -Fq "successfully submitted" PKI.CAServer.cls
    then
        rm -f PKI.CAServer.cls
        success=1
    else
        rm -f PKI.CAServer.cls
        success=0
    fi

    echo $success
}

SubmitWithRetry() {
    submit_status=0
    local try_max=30
    local sleep_time=10

    for i in `seq 1 $try_max`;
    do
        echo "* Try Submit CSR Request. $i/$try_max"
        
        submit_status=$(SubmitCSRRequest)
        if [ "$submit_status" = "1" ]
        then
            return $submit_status
        else
            echo "! Error occured "
        fi
        
        if [ $i -lt $try_max ]
        then
            echo "Next try in $sleep_time seconds..."
            sleep $sleep_time
        fi

    done

    return $submit_status
}

# After getting the certificate whe must to extract the certifcate content from the xml response
# and store in a file
ExtractCertificate() {
    local response_file=$1
    local output_file=$2
    local first_line=$(grep -n "<Contents>" $response_file | head -n 1 | cut -d: -f1)
    first_line=$((first_line+1))
    local last_line=$(grep -n "</Contents>" $response_file | head -n 1 | cut -d: -f1)
    last_line=$((last_line-1))
    filesubstr=$(sed -n "$first_line,$last_line p" $response_file)
    printf -- "-----BEGIN CERTIFICATE-----\n">$output_file
    printf "$filesubstr">>$output_file
}

GetCertificate() {
    
    local certificate_number=$1
    
    wget --no-check-certificate --quiet \
    --method POST \
    --timeout=0 \
    --header 'Content-Type: text/xml; charset=utf-8' \
    --header 'SOAPAction: http://pki.intersystems.com/PKI.CAServer.GetCertificate' \
    --header 'Cookie: CSPSESSIONID-SP-81-UP-isc-pki-=000000000000B8x0QrAT4PN6gCSV2SDi4i5u1s81uzT4Uvxkxz; CSPWSERVERID=hzYoK7sO' \
    --body-data '<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <GetCertificate xmlns="http://pki.intersystems.com">
      <number>'$certificate_number'</number>
    </GetCertificate>
  </soap:Body>
</soap:Envelope>
' \
   "http://$PKISRV/isc/pki/PKI.CAServer.cls"

    ExtractCertificate $DFLTRESPONSEFILE $2
    rm -f $DFLTRESPONSEFILE
}

# Certificate can be retrieve only with his number.
# but before it must be accepted by the KPI Server.
# this function call periodically PKI Server until the certificate is validated
GetCertificateNumber() {
    certificate_number=0
    local try_max=30
    local sleep_time=10

    for i in `seq 1 $try_max`;
    do
        echo "* Try Retrieve certificate number. $i/$try_max"
        
        GetList

        if grep -Fq "<Number>" $DFLTRESPONSEFILE
        then
            local nline=$(grep -n "<Number>" $DFLTRESPONSEFILE | tail -1 | head -n 1 | cut -d: -f1)
            extractline=$(sed -n "$nline p" $DFLTRESPONSEFILE)
            certificate_number=$( echo $extractline | cut -d'<' -f 2 | cut -d'>' -f 2 )
            echo "+ Certificate number found is $certificate_number"
            rm -f $DFLTRESPONSEFILE
            return 1
        fi

        
        
        if [ $i -lt $try_max ]
        then
            echo "Next try in $sleep_time seconds..."
            sleep $sleep_time
        fi

    done
    
    rm -f $DFLTRESPONSEFILE

}

CheckMatch() {
    CERTMATCH=0
    ZMD5CER=$(openssl x509 -noout -modulus -in $CERTFILENAME | openssl md5)
    ZMD5KEY=$(openssl rsa -noout -modulus -in $KEYFILE | openssl md5)
    ZMD5CSR=$(openssl req -noout -modulus -in $CSRFILE | openssl md5)
    if [ "$ZMD5CER" = "$ZMD5KEY" ] && [ "$ZMD5CER" = "$ZMD5CSR" ]
    then
        CERTMATCH=1
    fi
}

GetList() {
    rm -f $DFLTRESPONSEFILE
    wget --no-check-certificate --quiet \
  --method POST \
  --timeout=0 \
  --header 'Content-Type: text/xml; charset=utf-8' \
  --header 'SOAPAction: http://pki.intersystems.com/PKI.CAServer.ListCertificates' \
  --header 'Cookie: CSPSESSIONID-SP-81-UP-isc-pki-=000000000000B8x0QrAT4PN6gCSV2SDi4i5u1s81uzT4Uvxkxz; CSPWSERVERID=hzYoK7sO' \
  --body-data '<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
  <soap:Body>
    <ListCertificates xmlns="http://pki.intersystems.com">
      <hostname>'$MYHOSTNAME'</hostname>
      <instance>webgateway</instance>
    </ListCertificates>
  </soap:Body>
</soap:Envelope>
' \
   "http://$PKISRV/isc/pki/PKI.CAServer.cls"
}

# Remove file if exists (due to a previous execution).  
rm -vf $REQUESTBODYCSR $CSRFILE $KEYFILE PKI.CAServer.cls CA_Server.cer $CERTFILENAME

# Generate private key file a certifate request.  
openssl req -new -newkey rsa:2048 -nodes -keyout $KEYFILE -subj "$CSRSUBJECT" -out $CSRFILE

# Prepare the xml soap body before send the request to the PKI Server
PrepareRequestBodyCSR

# Submit the certificate request to the PKI Server.
SubmitWithRetry

if [ "$submit_status" = 0 ]
then
    exit 1
fi

# Get CA_Server certificate
GetCertificate 0 "CA_Server.cer"

CERTMATCH=0

while [ $CERTMATCH -lt 1 ]
do
    GetCertificateNumber
    
    if [ "$certificate_number" = 0 ]
    then
        exit 1
    fi

    GetCertificate $certificate_number $CERTFILENAME

    CheckMatch

    if [ "$CERTMATCH" = "0" ]
    then
        echo "! Certifcate $CERTFILENAME did not match with the private key and request."
        echo "! Retrieved certificate match probably with a previous attempt."
        echo "! Expected certificate is not yet signed, wait 10 seconds and retry."
        rm -vf $CERTFILENAME
        sleep 10
    fi

done

rm -f $REQUESTBODYCSR



chgrp www-data $KEYFILE
chmod 640 $KEYFILE

mv $CSRFILE ${ISC_DATA_DIRECTORY:-/opt/webgateway/bin/}
mv $KEYFILE ${ISC_DATA_DIRECTORY:-/opt/webgateway/bin/}
mv $CERTFILENAME ${ISC_DATA_DIRECTORY:-/opt/webgateway/bin/}
mv CA_Server.cer ${ISC_DATA_DIRECTORY:-/opt/webgateway/bin/}

exit 0