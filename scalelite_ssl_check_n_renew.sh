#!/bin/bash

# Check the certificate and renew it if the it due for renewal in next 14 days i.e. 1209600 seconds

export DomainName=$1
export SSLChekerFolder=/root/ssl_checker/logs

{

Help()
{
   # Display Help
   echo "Please provide all required aurguments - Syntax: scriptFormat"
   echo
   echo "./ssl_check_n_renew.sh <Domain Name>"
   echo
}

if [ "$#" -lt 1 ]
  then
    Help
    exit 0
fi

if [ -d $SSLChekerFolder ]
then
        echo "Folder Already Exist"
else
        sudo mkdir -p $SSLChekerFolder
        echo "New deployment folder created successfully i.e. $SSLChekerFolder"
fi

if [ `openssl x509 -checkend 1209600 -noout -in /etc/letsencrypt/live/$DomainName/cert.pem ; echo $?` -eq 0 ]
then
        systemctl stop scalelite-nginx.service
        sleep 10
        sudo systemctl start nginx
        echo "Certificate is up-to-date, no renewal is required...."
        /usr/bin/certbot renew --cert-name $DomainName --quiet
        sleep 10
        sudo systemctl restart nginx
        sleep 10
        systemctl start scalelite-nginx.service
else
        echo "Certificate is due for renewal, hence renewing it"
fi

find $SSLChekerFolder/ -type f -mtime +14 -exec rm {} \;

} 2>&1 | tee "$SSLChekerFolder"/ssl_check_`date "+%y%m%d%H%M"`.log