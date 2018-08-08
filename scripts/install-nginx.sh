#!/bin/sh

set -e;

apk update;
apk add nginx supervisor;

# configure NGINX
cat <<'EOF' >/etc/nginx/conf.d/utf8.conf
charset UTF-8;
EOF

cat <<'EOF' >/etc/nginx/conf.d/gzip.conf
gzip on;
gzip_disable "msie6";
 
gzip_vary on;
gzip_proxied off;
gzip_comp_level 6;
gzip_buffers 16 8k;
gzip_min_length 50;
gzip_http_version 1.0;
gzip_types gzip_types text/plain text/css application/json application/x-javascript text/xml application/xml application/xml+rss text/javascript application/javascript application/x-font-ttf application/x-font-opentype image/svg+xml image/x-icon application/atom_xml;
EOF

sed -i -r 's/^(\s+)client_max_body_size ([0-9]+)m;$/\1client_max_body_size 20m;/' /etc/nginx/nginx.conf
sed -i -r 's/^(\s+)gzip on;$/\1# gzip on;/' /etc/nginx/nginx.conf
sed -i -r 's/^(\s+)gzip_vary on;$/\1# gzip_vary on;/' /etc/nginx/nginx.conf

mkdir /etc/nginx/conf.d.server
 
cat <<'EOF' >/etc/nginx/conf.d.server/blockdot.conf
location ~ /\. {
    deny all;
    access_log off;
    log_not_found off;
}
EOF

cat <<'EOF' >/etc/nginx/conf.d.server/nolog_favrob.conf
location = /favicon.ico {
    access_log off;
    log_not_found off;
}
 
location = /robots.txt {
    access_log off;
    log_not_found off;
}
EOF

cat <<'EOF' >/etc/nginx/conf.d.server/phpfpm.conf
    fastcgi_split_path_info ^(.+?\.php)(/.*)$;
    try_files $fastcgi_script_name =404;
    fastcgi_pass unix:/var/run/php7-fpm.sock;
    fastcgi_index index.php;
    include fastcgi.conf;
EOF

cat <<'EOF' >/etc/nginx/conf.d.server/docker_realip.conf
# Module ngx_http_realip_module
# http://nginx.org/en/docs/http/ngx_http_realip_module.html
set_real_ip_from 10.0.0.0/8;
set_real_ip_from 172.16.0.0/12;
real_ip_header X-Forwarded-For;
EOF

# configure PHP-FPM
sed -i \
    -e 's/^user =.*/user = project/' \
    -e 's/^group =.*/group = project/' \
    -e 's/^listen =.*/listen = \/var\/run\/php7-fpm.sock/' \
    -e 's/^;listen.owner =.*/listen.owner = nginx/' \
    -e 's/^;listen.group =.*/listen.group = nginx/' \
    -e 's/^;catch_workers_output =.*/catch_workers_output = yes/' \
    /etc/php7/php-fpm.d/www.conf

# configure supervisord
cat <<'EOF' >/etc/supervisord.conf
[unix_http_server]
file=/tmp/supervisor.sock

[supervisord]
logfile=/tmp/supervisord.log
logfile_maxbytes=5MB
pidfile=/tmp/supervisord.pid
user=root
nodaemon=true
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0

[include]
files=/etc/supervisor/conf.d/*.conf

[rpcinterface:supervisor]
supervisor.rpcinterface_factory=supervisor.rpcinterface:make_main_rpcinterface

[supervisorctl]
serverurl=unix:///tmp/supervisor.sock ; use a unix:// URL  for a unix socket

EOF

mkdir -p /etc/supervisor/conf.d/

cat <<'EOF' >/etc/supervisor/conf.d/nginx.conf
[program:nginx]
command=/usr/sbin/nginx -g "pid /tmp/nginx.pid; daemon off;"
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stdout_events_enabled=true
stderr_events_enabled=true
autostart=true
autorestart=true
priority=500
EOF

cat <<'EOF' >/etc/supervisor/conf.d/php-fpm.conf
[program:php-fpm]
command=/usr/sbin/php-fpm7 --nodaemonize --force-stderr
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stdout_events_enabled=true
stderr_events_enabled=true
autostart=false
autorestart=true
priority=400
EOF

