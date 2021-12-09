FROM alpine AS builder

ENV NGINX_VERSION 1.21.4

RUN apk update \ 
  && apk add --update alpine-sdk build-base cmake linux-headers libressl-dev pcre-dev zlib-dev

RUN wget  -qO- http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz | tar -zxf - \
  && cd nginx-${NGINX_VERSION} \
  && ./configure \
    --prefix=/etc/nginx \
    --sbin-path=/etc/nginx/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --with-pcre-jit \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_gzip_static_module \
    --with-http_gunzip_module \
    --with-http_realip_module \
    --with-http_stub_status_module \
    --with-http_auth_request_module \
    --with-http_addition_module \
    --with-http_sub_module \
    --with-compat && \
  make -j2 && \
  make install && \
  make clean

RUN mkdir -p /var/log/nginx/ && \
    echo -n > /var/log/nginx/access.log && \
    echo -n > /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

STOPSIGNAL SIGQUIT
EXPOSE 80

CMD ["/etc/nginx/nginx", "-g", "daemon off;"]