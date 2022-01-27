#!bin/bash

iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END
zpm "install config-api"
zpm "install pki-script"

Do ##class(lscalese.pki.Utils).MirrorMaster(,"",,,,"IRIS,WEBGATEWAY")
; Event if it's not a mirror install, we can use MirrorMaster utility method
; this is a short way to execute the lines below : 
;  Do ##class(lscalese.pki.Server).MinimalServerConfig("\$server_password\$", "US", "CASrv", 365)
;  Job ##class(lscalese.pki.Server).SignAllRequestWhile("\$server_password\$",900,"*")
;  Do ##class(lscalese.pki.Client).MinimalClientConfig("iris:52773","Contact Name")
;  Do ##class(lscalese.pki.Client).RequestCertificate("","US",,"iris_client")
;  Do ##class(lscalese.pki.Client).WaitSigning(,,.number)
;  Do ##class(lscalese.pki.Client).GetRequestedCertificate(number)

; Load a config-api file to create the %SuperServer SSL Config
Do ##class(Api.Config.Services.Loader).Load("/opt/config-files/iris-config.json")

Halt
END

exit 0