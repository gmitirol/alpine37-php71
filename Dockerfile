ARG REGISTRY_PATH=gmitirol
FROM $REGISTRY_PATH/alpine37:1.1.10
LABEL maintainer="gmi-edv@i-med.ac.at"

ADD scripts/ /usr/local/bin/
ADD tools/ /usr/local/bin/

# install PHP7 + extensions, disable non-default extensions
RUN set -xe && \
  sh /usr/local/bin/install-php.sh && \
  rm /usr/local/bin/install-php.sh && \
  sh /usr/local/bin/php-ext.sh disable-non-default && \
  sh /usr/local/bin/php-ext.sh show && \
  sh /usr/local/bin/install-nginx.sh && \
  rm /usr/local/bin/install-nginx.sh && \
  echo 'TLS_CACERT /etc/ssl/certs/ca-certificates.crt' >> /etc/openldap/ldap.conf

RUN set -xe && \
  /bin/sed -i \
    -e 's#^expose_php =.*#expose_php = Off#' \
    -e "s#^;date\.timezone =.*#date.timezone = $(cat /etc/TZ)#" \
    /etc/php7/php.ini

# install composer and tools
RUN set -xe && \
  sh /usr/local/bin/install-composer.sh && \
  rm /usr/local/bin/install-composer.sh && \
  mv /usr/local/bin/sami4.phar /usr/local/bin/sami && \
  mv /usr/local/bin/phpcs3.phar /usr/local/bin/phpcs

# create locked project user with user ID 1000
RUN set -xe && \
  adduser -u 1000 -D project;

# add build info
ADD PHP_BUILD /

# optionally store github token in image
ARG GITHUB_TOKEN
RUN if [ -n "$GITHUB_TOKEN" ] ; then \
      sh /usr/local/bin/setup-github-token.sh $GITHUB_TOKEN ; \
    fi
