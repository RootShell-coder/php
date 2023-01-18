#!/bin/bash

PHP=5.4.45

if [ -n "$TZ" ]; then
    sed -i 's;\;date.timezone =;date.timezone = '"$TZ"';' /usr/local/php-${PHP}/etc/php.ini
    sed -i 's;Europe/Moscow;'"$TZ"';' /usr/local/php-${PHP}/etc/local/php-ext-timezone.ini
    rm /etc/localtime && \
    ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata
fi

if [ -n "$HOSTNAME" ]; then
    echo $HOSTNAME
    sed -i 's;\#ServerName www.example.com;ServerName '"$HOSTNAME"';' /etc/apache2/sites-available/000-default.conf
    # sed  -i '/dc_other_hostnames=/s/[^.]*$/'"dc_other_hostnames='"$HOSTNAME"'/" /etc/exim4/update-exim4.conf.conf
    # echo $HOSTNAME > /etc/hostname
    # echo "127.0.0.1 "$HOSTNAME >> /etc/hosts
fi

if [ -n "$TRUSTEDPROXY" ]; then
    sed -i "s;dc_smarthost='';dc_smarthost='$TRUSTEDPROXY';" /etc/exim4/update-exim4.conf.conf
    sed -i 's;127.0.0.1;'$TRUSTEDPROXY';' /etc/apache2/conf-available/remoteip.conf
fi

if [ -n "$EMAIL" ]; then
    sed -i 's;\;mail.force_extra_parameters =;mail.force_extra_parameters = '"$EMAIL"';' /usr/local/php-${PHP}/etc/php.ini
    sed -i 's;\;sendmail_path =;sendmail_path = /usr/sbin/sendmail -t -i -f '"$EMAIL"';' /usr/local/php-${PHP}/etc/php.ini
    sed -i 's;webmaster@localhost;'"$EMAIL"';' /etc/apache2/sites-available/000-default.conf
fi

if [ -n "$CHOWN" && "$CHOWN" = 'true' ]; then
    chown -R 33:33 /var/www/html/*
fi

/usr/local/dkim/gen_dkim.sh
update-exim4.conf
exec "$@"
