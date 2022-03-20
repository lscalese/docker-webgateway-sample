#!/bin/bash
iris start iris

iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END
zpm "install pki-script"
Do ##class(lscalese.pki.Server).MinimalServerConfig("\$server_password\$", "US", "CASrv", 365)
Do ##class(lscalese.pki.Client).MinimalClientConfig("localhost:52773","Contact Name")
Job ##class(lscalese.pki.Server).SignAllRequestWhile("\$server_password\$",900,"*")
Halt
END

cp /usr/irissys/mgr/CA_Server.cer /external/certificates/CA_Server.cer

while [ $# -gt 0 ]
do
    CASUBJECT=$1
    CURRENTCERT=$2
  
iris session $ISC_PACKAGE_INSTANCENAME -U %SYS <<- END
Set subj="${CASUBJECT}"
Set file="${CURRENTCERT}"
For i=2:1:\$l(subj,"/") Set k=\$Piece(\$Piece(subj,"/",i),"=") Set:k'="" arr(k)=\$Piece(\$Piece(subj,"/",i),"=",2,*)
Set attr=\$ListBuild(\$Get(arr("C")), \$Get(arr("ST")), \$Get(arr("L")), \$Get(arr("O")), \$Get(arr("OU")), \$Get(arr("CN")) )
Do ##class(lscalese.pki.Client).RequestCertificateByAttr("",attr,file)
Do ##class(lscalese.pki.Client).WaitSigning(,,.number)
Do ##class(lscalese.pki.Client).GetRequestedCertificate(number)
Halt
END

    # cp /usr/irissys/mgr/${CURRENTCERT}.csr /external/certificates/${CURRENTCERT}.csr
    cp /usr/irissys/mgr/${CURRENTCERT}.cer /external/certificates/${CURRENTCERT}.cer
    cp /usr/irissys/mgr/${CURRENTCERT}.key /external/certificates/${CURRENTCERT}.key

  shift
  shift
done


iris stop iris quietly