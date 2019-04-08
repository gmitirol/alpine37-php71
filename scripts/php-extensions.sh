#!/bin/sh

function get_php_extensions() {
    EXTENSIONS='
php7-apcu
php7-bcmath
php7-bz2
php7-calendar
php7-ctype
php7-curl
php7-dom
php7-exif
php7-fileinfo
php7-gd
php7-gettext
php7-gmp
php7-imagick
php7-imap
php7-intl
php7-json
php7-ldap
php7-mbstring
php7-mcrypt
php7-memcached
php7-mysqli
php7-mysqlnd
php7-opcache
php7-openssl
php7-pcntl
php7-pdo
php7-pdo_mysql
php7-pdo_sqlite
php7-phar
php7-posix
php7-session
php7-shmop
php7-simplexml
php7-sockets
php7-sqlite3
php7-tokenizer
php7-xdebug
php7-xml
php7-xmlreader
php7-xmlwriter
php7-xsl
php7-zip
';
# php7-zlib is not installed, as it is only a virtual package.
# The extensions php7-redis and php7-iconv are not installed, as they are broken on alpine.
# Use symfony/polyfill-iconv respective predis/predis instead when necessary.

    echo "$EXTENSIONS";

    exit 0;
}

function get_php_extensions_default() {
    EXTENSIONS='
php7-ctype
php7-dom
php7-json
php7-mbstring
php7-openssl
php7-phar
php7-posix
php7-simplexml
php7-tokenizer
php7-xml
php7-xmlwriter
php7-zip
';

    echo "$EXTENSIONS";

    exit 0;
}
