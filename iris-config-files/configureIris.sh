#!bin/bash

iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END

zpm "install config-api"
Do ##class(Api.Config.Services.Loader).Load("/opt/config-files/iris-config.json")

Halt
END

exit 0