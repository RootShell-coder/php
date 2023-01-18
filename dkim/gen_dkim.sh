#!/bin/bash

KEYDIR=/etc/mail
OPENSSLDIR=/usr/local/openssl-1.0.2u/bin
CURLDIR=/usr/local/curl-7.82.0/bin

if [ -f $KEYDIR/$HOSTNAME.key -a -f $KEYDIR/$HOSTNAME.pub ]; then
    MYIP=`$CURLDIR/curl https://polmira.ru/ip.php`
    DKIM=`cat $KEYDIR/$HOSTNAME.pub | sed -e 's/-----BEGIN PUBLIC KEY-----//' -e 's/-----END PUBLIC KEY-----//' | \
        tr -d '\n' | sed -r 's/(.){197}/"v=DKIM1; g=*; k=rsa; p=&\n"/g' | sed 's/$/"/'`
    echo ""
    echo "Publish your public key to your DNS record as a text (TXT) record."
    echo "Check with your DNS provider to see if they allow more than 255 characters in the input field or not,"
    echo "as you may have to work with your provider to increase the size or to create the TXT record itself."
    echo ""
    echo "dkim._domainkey."$HOSTNAME" TXT "$DKIM
    echo ""
    echo "And add SPF TXT record \"v=spf1 ip4:"$MYIP" ~all\""
    echo ""
else
    mkdir $KEYDIR/
    $OPENSSLDIR/openssl genrsa -out $KEYDIR/$HOSTNAME.key 2048
    $OPENSSLDIR/openssl rsa -in $KEYDIR/$HOSTNAME.key -out $KEYDIR/$HOSTNAME.pub -pubout -outform PEM

    chown -R root:Debian-exim $KEYDIR
    chmod 0640 $KEYDIR/$HOSTNAME.key
fi
