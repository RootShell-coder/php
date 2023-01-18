FROM debian:11.6-slim as build

ENV OPENSSL=1.0.2u
ENV PHP=5.4.45
ENV FREETYPE=2.6.5
ENV CURL=7.82.0
ENV ICONV=1.15
#ENV ICU=55.1

RUN apt-get update && apt-get install -y \
  wget apt-utils build-essential autoconf automake \
  zlib1g-dev libbz2-dev libmcrypt-dev libpq-dev default-libmysqld-dev \
  libxslt-dev libjpeg62-turbo-dev libpng-dev apache2-dev apache2 \
  libtool libxml2 libxml2-dev libbz2-1.0 libbz2-dev libjpeg-dev libmcrypt4 \
  libxslt1.1 libxslt1-dev libxt-dev libxpm-dev libgmp-dev libreadline-dev \
  libpcre3 libpcre3-dev \
  && apt-get clean && apt-get autoclean \
  && rm -rf /var/lib/apt/lists /tmp/*

#openssl
RUN mkdir -p /usr/local/openssl-${OPENSSL} \
  && wget -O /usr/local/src/openssl-${OPENSSL}.tar.gz https://www.openssl.org/source/openssl-${OPENSSL}.tar.gz \
  && cd /usr/local/src \
  && tar -xf openssl-${OPENSSL}.tar.gz \
  && rm -f openssl-${OPENSSL}.tar.gz \
  && cd openssl-${OPENSSL} \
  && make clean \
  && ./config shared --prefix=/usr/local/openssl-${OPENSSL} \
  && make -j $(nproc) \
  && make test \
  && make install \
  && ls -la /usr/local/openssl-${OPENSSL}/lib \
  && wget -O /usr/local/openssl-${OPENSSL}/ssl/cert.pem "http://curl.haxx.se/ca/cacert.pem" \
  && ln -s /usr/local/openssl-${OPENSSL}/lib /usr/local/openssl-${OPENSSL}/lib/x86_64-linux-gnu \
  && ln -s /usr/local/openssl-${OPENSSL}/lib/libcrypto.so.1.0.0 /usr/lib/x86_64-linux-gnu \
  && ln -s /usr/local/openssl-${OPENSSL}/lib/libssl.so.1.0.0 /usr/lib/x86_64-linux-gnu

#curl
RUN mkdir -p /usr/local/curl-${CURL} \
  && wget -O /usr/local/src/curl-${CURL}.tar.gz https://curl.se/download/curl-${CURL}.tar.gz \
  && cd /usr/local/src \
  && tar -xf curl-${CURL}.tar.gz \
  && rm -f curl-${CURL}.tar.gz \
  && cd curl-${CURL} \
  && ./configure --with-openssl=/usr/local/openssl-${OPENSSL} --prefix=/usr/local/curl-${CURL} \
  && make -j $(nproc) \
  && make install

#freetype
RUN mkdir -p /usr/local/freetype-${FREETYPE} \
  && wget -O /usr/local/src/freetype-${FREETYPE}.tar.gz https://download.savannah.gnu.org/releases/freetype/freetype-old/freetype-${FREETYPE}.tar.gz \
  && cd /usr/local/src \
  && tar -xf freetype-${FREETYPE}.tar.gz \
  && rm -f freetype-${FREETYPE}.tar.gz \
  && cd freetype-${FREETYPE} \
  && ./configure --prefix=/usr/local/freetype-${FREETYPE} \
  && make -j $(nproc) \
  && make install

#iconv
RUN mkdir -p /usr/local/libiconv-${ICONV} \
  && wget -O /usr/local/src/libiconv-${ICONV}.tar.gz https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${ICONV}.tar.gz \
  && cd /usr/local/src \
  && tar -xf libiconv-${ICONV}.tar.gz \
  && rm -f libiconv-${ICONV}.tar.gz \
  && cd libiconv-${ICONV} \
  && ./configure --prefix=/usr/local/libiconv-${ICONV} \
  && make -j $(nproc) \
  && make install

#php-fpm
RUN mkdir -p /usr/local/src/php-${PHP} \
  && wget -O /usr/local/src/php-${PHP}.tar.gz https://www.php.net/distributions/php-${PHP}.tar.gz \
  && cd /usr/local/src \
  && tar -xf php-${PHP}.tar.gz \
  && rm -f php-${PHP}.tar.gz \
  && cd php-${PHP} \
  && ln -s /usr/lib/x86_64-linux-gnu/libXpm.so /usr/lib/ \
  && ln -s /usr/lib/x86_64-linux-gnu/libXpm.a /usr/lib/ \
  && export APACHE_RUN_DIR=/var/run/apache2 \
  && ./configure \
  --prefix=/usr/local/php-${PHP}/ \
  --exec-prefix=/usr/local/php-${PHP}/  \
  --with-config-file-path=/usr/local/php-${PHP}/etc/ \
  --with-config-file-scan-dir=/usr/local/php-${PHP}/etc/local/ \
  --localstatedir=/usr/local/php-${PHP}/var/ \
  \
  --disable-all \
  --disable-cgi \
  --disable-debug \
  \
  --enable-cli \
  --enable-fpm \
  --enable-mbstring \
  --enable-libxml \
  --enable-mysqlnd \
  --enable-ctype \
  --enable-shmop \
  --enable-pcntl \
  --enable-fileinfo \
  --enable-pdo \
  --enable-dom \
  --enable-bcmath \
  --enable-calendar \
  --enable-exif \
  --enable-ftp \
  --enable-inline-optimization \
  --enable-soap \
  #--enable-intl #need build ICU ~ 55.1
  --enable-sockets \
  --enable-sysvmsg \
  --enable-sysvsem \
  --enable-sysvshm \
  --enable-zip \
  --enable-ftp \
  --enable-json \
  --enable-filter \
  --enable-tokenizer \
  --enable-posix \
  --enable-session \
  --enable-xml \
  --enable-simplexml \
  --enable-xmlreader \
  --enable-xmlwriter \
  --enable-phar \
  --enable-wddx \
  --enable-option-checking=fatal \
  --with-curl=/usr/local/curl-${CURL} \
  --with-mcrypt \
  --with-bz2 \
  \
  --with-gd \
  --with-freetype-dir=/usr/local/freetype-${FREETYPE} \
  --with-jpeg-dir=/usr \
  --with-readline \
  --with-xpm-dir=/usr \
  --with-png-dir=/usr \
  --with-layout=GNU \
  --with-libxml-dir=/usr \
  --with-zlib-dir=/usr \
  --with-litespeed \
  --with-tsrm-pthreads \
  --with-fpm-user=www-data \
  --with-fpm-group=www-data \
  --with-kerberos \
  --with-iconv=/usr/local/libiconv-${ICONV} \
  --with-openssl=/usr/local/openssl-${OPENSSL} \
  --with-gettext=/usr \
  --with-mhash \
  --with-mysql \
  --with-mysqli \
  --with-pdo-mysql \
  --with-sqlite3 \
  --with-pdo-sqlite \
  --with-pcre-regex \
  --with-regex=php \
  --with-pear \
  --with-xsl \
  --with-libxml-dir=/usr \
  --with-zlib \
  && make -j $(nproc) \
  && make test \
  && make install \
  && cp /usr/local/src/php-${PHP}/php.ini-production /usr/local/php-${PHP}/etc/php.ini \
  && ls -la /usr/local


FROM debian:11.6-slim

LABEL maintainer="Root Shell <Root.Shelling@gmail.com>"

ENV DEBIAN_FRONTEND noninteractive
ENV LANG='ru_RU.UTF-8' LANGUAGE='ru_RU:ru' LC_ALL='ru_RU.UTF-8'
ENV OPENSSL=1.0.2u
ENV PHP=5.4.45
ENV FREETYPE=2.6.5
ENV CURL=7.82.0
ENV ICONV=1.15

RUN apt-get update -y && apt-get install -y apache2 apache2-utils libapache2-mod-fcgid \
  libtool libxml2 libbz2-1.0 libmcrypt4 libxslt1.1 xsltproc default-mysql-client \
  mcrypt libpcre3 exim4 locales locales-all tzdata supervisor \
  && apt-get clean && apt-get autoclean \
  && rm -rf /var/lib/apt/lists /tmp/*

COPY --from=build /usr/local/openssl-${OPENSSL} /usr/local/openssl-${OPENSSL}
COPY --from=build /usr/local/curl-${CURL} /usr/local/curl-${CURL}
COPY --from=build /usr/local/freetype-${FREETYPE} /usr/local/freetype-${FREETYPE}
COPY --from=build /usr/local/libiconv-${ICONV} /usr/local/libiconv-${ICONV}
COPY --from=build /usr/local/php-${PHP}/ /usr/local/php-${PHP}/
COPY --from=build /usr/lib/apache2/modules/ /usr/lib/apache2/modules/
COPY --from=build /etc/apache2/mods-available /etc/apache2/mods-available
COPY apache2/apache2.conf /etc/apache2/
COPY apache2/default.conf /etc/apache2/sites-available/000-default.conf
COPY php-fpm /usr/local/php-5.4.45/etc
COPY entrypoint.sh /usr/bin/entrypoint.sh
COPY supervisor /etc/supervisor
COPY dkim /usr/local/dkim
COPY exim4 /etc/exim4

RUN ln -s /usr/local/openssl-${OPENSSL}/lib/libcrypto.so.1.0.0 /usr/lib/x86_64-linux-gnu \
  && ln -s /usr/local/openssl-${OPENSSL}/lib/libssl.so.1.0.0 /usr/lib/x86_64-linux-gnu \
  && ln -s /usr/local/curl-${CURL}/bin/curl /usr/bin/curl \
  && ln -s /usr/lib/x86_64-linux-gnu/libXpm.so /usr/lib/ \
  && ln -s /usr/lib/x86_64-linux-gnu/libXpm.a /usr/lib/ \
  && export APACHE_RUN_DIR=/var/run/apache2 \
  && echo "<?php\nerror_reporting(E_ERROR | E_WARNING | E_PARSE | E_NOTICE);\necho \$undef;\nphpinfo();\n" > /var/www/html/nfo.php \
  && echo "RemoteIPHeader X-Forwarded-For\nRemoteIPTrustedProxy 127.0.0.1" > /etc/apache2/conf-available/remoteip.conf \
  && ln -sf /dev/stdout /var/log/apache2/access.log \
  && ln -sf /dev/stderr /var/log/apache2/error.log \
  && ln -sf /usr/local/php-${PHP}/var/log /var/log/php \
  && ln -sf /usr/local/php-${PHP}/var/run/ /var/run/php \
  && mkdir /usr/local/php-${PHP}/tmp \
  && chown -R 33:33 /var/www/html/* \
  && chown -R 33:33 /usr/local/php-${PHP}/tmp \
  && chmod +x /usr/local/dkim/gen_dkim.sh \
  && chmod +x /usr/bin/entrypoint.sh \
  && a2enmod remoteip rewrite proxy proxy_fcgi \
  && a2enconf remoteip \
  && locale-gen ru_RU.UTF-8 \
  && PATH=$PATH:/usr/local/php-${PHP}/bin \
  && export PATH

WORKDIR /var/www/html
VOLUME /var/www/html
VOLUME /etc/mail
EXPOSE 80
ENTRYPOINT [ "entrypoint.sh" ]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
