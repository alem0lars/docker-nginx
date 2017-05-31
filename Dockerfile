FROM alpine:3.6

MAINTAINER Alessandro Molari <molari.alessandro@gmail.com> (alem0lars)

# == BASIC SOFTWARE ============================================================

RUN apk update \
 && apk upgrade

# == ENV / PARAMS ==============================================================

ENV HTTPD_USER httpd
ENV HTTPD_HOME /home/httpd

# == USER / GROUP ==============================================================

RUN adduser -D $HTTPD_USER -h $HTTPD_HOME -s /bin/bash

# == APP =======================================================================

RUN apk add --update --no-cache nginx nginx-naxsi

ADD dist/nginx.conf          /etc/nginx/nginx.conf
ADD dist/conf.d/default.conf /etc/nginx/conf.d/default
ADD dist/conf.d/badbot.conf  /etc/nginx/conf.d/badbot.conf
ADD dist/sites               /etc/nginx/sites-enabled/

# == LOGROTATE =================================================================

RUN apk add --update --no-cache logrotate

RUN mv /etc/periodic/daily/logrotate /etc/periodic/hourly/logrotate

ADD dist/logrotate.conf /etc/logrotate.d/nginx

# == RSYSLOG ===================================================================

RUN apk add --update --no-cache rsyslog

ADD dist/rsyslog.conf /etc/rsyslog.d/90-nginx.conf

# == SUPERVISORD ===============================================================

RUN apk add --update --no-cache supervisor

ADD dist/supervisord.ini /etc/supervisor.d/supervisord.ini

# == TOOLS (useful when inspecting the container) ==============================

RUN apk add --update --no-cache vim bash-completion tmux

# == ENTRYPOINT ================================================================

EXPOSE 80
EXPOSE 443

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]
