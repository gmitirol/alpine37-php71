#!/bin/sh

set -e;

CONFIGURATION="$1";
WEBROOT="$2";

if [ -z "$CONFIGURATION" ]; then
    echo 'Usage: setup-nginx.sh <config> [webroot]';

    exit 64;
fi;

if [ -z "$WEBROOT" ]; then
    WEBROOT='/home/project/www';
fi;

case "$CONFIGURATION" in
    'static')
        # This configuration profile sets up the NGINX webserver without PHP-FPM.
        # Use case example: A periodically executed PHP script generates static files to be served via NGINX.
cat <<EOF >/etc/nginx/conf.d/default.conf
server {
    listen 80;

    root $WEBROOT;
    index index.html index.htm;

    include /etc/nginx/conf.d.server/blockdot.conf;
    include /etc/nginx/conf.d.server/nolog_favrob.conf;
    #include /etc/nginx/conf.d.server/docker_realip.conf;

    ##PLACEHOLDER_CUSTOM_CONFIGURATION##

    access_log /dev/stdout;
    error_log /dev/stderr;

    location ~ \.php$ {
        return 404;
    }
}
EOF
        ;;
    'php')
        # This configuration profile sets up the NGINX webserver with basic PHP-FPM configuration.
        # Use case example: Simple PHP web application.
        cat <<EOF >/etc/nginx/conf.d/default.conf
server {
    listen 80;

    root $WEBROOT;
    index index.php index.html index.htm;

    include /etc/nginx/conf.d.server/blockdot.conf;
    include /etc/nginx/conf.d.server/nolog_favrob.conf;
    #include /etc/nginx/conf.d.server/docker_realip.conf;

    location ~ [^/]\.php(/|$) {
        include /etc/nginx/conf.d.server/phpfpm.conf;
    }

    ##PLACEHOLDER_CUSTOM_CONFIGURATION##

    access_log /dev/stdout;
    error_log /dev/stderr;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
        sed -i -r 's/^(autostart=)false$/\1true/' /etc/supervisor/conf.d/php-fpm.conf
        ;;
    'symfony')
        # This configuration profile sets up the NGINX webserver with PHP-FPM configured for symfony apps.
        # Use case example: Full-stack symfony 2.x/3.x application.
        cat <<EOF >/etc/nginx/conf.d/default.conf
server {
    listen 80;

    root $WEBROOT;
    index app.php;

    include /etc/nginx/conf.d.server/blockdot.conf;
    include /etc/nginx/conf.d.server/nolog_favrob.conf;
    #include /etc/nginx/conf.d.server/docker_realip.conf;

    ##PLACEHOLDER_CUSTOM_CONFIGURATION##

    access_log /dev/stdout;
    error_log /dev/stderr;

    location / {
        try_files \$uri /app.php\$is_args\$args;
    }

    location ~ ^/app\.php(/|$) {
        include /etc/nginx/conf.d.server/phpfpm.conf;
        internal;
    }

    location ~ \.php$ {
        return 404;
    }
}
EOF
        sed -i -r 's/^(autostart=)false$/\1true/' /etc/supervisor/conf.d/php-fpm.conf
        ;;
    'symfony4')
        # This configuration profile sets up the NGINX webserver with PHP-FPM configured for symfony apps.
        # Use case example: Full-stack symfony 4.x application.
        cat <<EOF >/etc/nginx/conf.d/default.conf
server {
    listen 80;

    root $WEBROOT;
    index index.php;

    include /etc/nginx/conf.d.server/blockdot.conf;
    include /etc/nginx/conf.d.server/nolog_favrob.conf;
    #include /etc/nginx/conf.d.server/docker_realip.conf;

    ##PLACEHOLDER_CUSTOM_CONFIGURATION##

    access_log /dev/stdout;
    error_log /dev/stderr;

    location / {
        try_files \$uri /index.php\$is_args\$args;
    }

    location ~ ^/index\.php(/|$) {
        include /etc/nginx/conf.d.server/phpfpm.conf;
        internal;
    }

    location ~ \.php$ {
        return 404;
    }
}
EOF
        sed -i -r 's/^(autostart=)false$/\1true/' /etc/supervisor/conf.d/php-fpm.conf
        ;;
    *)
        (>&2 echo 'Invalid configuration profile!');

        exit 65;
        ;;
esac