#!/bin/bash
iris start iris

iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END

zpm "install pki-script"

Do ##class(lscalese.pki.Server).MinimalServerConfig("\$server_password\$", "US", "CASrv", 365)
Do ##class(lscalese.pki.Client).MinimalClientConfig("localhost:52773","Contact Name")
Job ##class(lscalese.pki.Server).SignAllRequestWhile("\$server_password\$",900,"*")

Set attr=\$ListBuild("BE","Wallonia","Namur","Community","IT","webgateway")

Do ##class(lscalese.pki.Client).RequestCertificateByAttr("",attr,"webgateway_client")
Do ##class(lscalese.pki.Client).WaitSigning(,,.number)
Do ##class(lscalese.pki.Client).GetRequestedCertificate(number)

Do ##class(lscalese.pki.Client).RequestCertificateByAttr("",attr,"apache_webgateway")
Do ##class(lscalese.pki.Client).WaitSigning(,,.number)
Do ##class(lscalese.pki.Client).GetRequestedCertificate(number)

Do ##class(lscalese.pki.Client).RequestCertificateByAttr("",attr,"iris_server")
Do ##class(lscalese.pki.Client).WaitSigning(,,.number)
Do ##class(lscalese.pki.Client).GetRequestedCertificate(number)

Halt
END

# Copy certificates outside the container.

cp /usr/irissys/mgr/CA_Server.cer /external/certificates/CA_Server.cer

cp /usr/irissys/mgr/webgateway_client.csr /external/certificates/webgateway_client.csr
cp /usr/irissys/mgr/webgateway_client.cer /external/certificates/webgateway_client.cer
cp /usr/irissys/mgr/webgateway_client.key /external/certificates/webgateway_client.key

cp /usr/irissys/mgr/apache_webgateway.csr /external/certificates/apache_webgateway.csr
cp /usr/irissys/mgr/apache_webgateway.cer /external/certificates/apache_webgateway.cer
cp /usr/irissys/mgr/apache_webgateway.key /external/certificates/apache_webgateway.key

cp /usr/irissys/mgr/iris_server.csr /external/certificates/iris_server.csr
cp /usr/irissys/mgr/iris_server.cer /external/certificates/iris_server.cer
cp /usr/irissys/mgr/iris_server.key /external/certificates/iris_server.key


iris stop iris quietly
