FROM iquirino91/grpc AS builder

RUN wget -qO- https://github.com/nghttp2/nghttp2/releases/download/v1.46.0/nghttp2-1.46.0.tar.gz | tar -zxf - \
  && cd nghttp2-1.46.0 \
  && ./configure \
  && make -j2 \
  && make install

RUN wget -qO- https://curl.se/download/curl-7.80.0.zip | unzip -qq - \
  && cd curl-7.80.0 \
  && chmod 777 configure \
  && chmod 777 install-sh \
  && ./configure \
    --with-nghttp2=/usr/local --with-ssl --disable-dependency-tracking \
    --prefix=/usr \
    --enable-ipv6 \
    --enable-unix-sockets \
    --enable-static \
    --with-openssl \
    --without-libidn \
    --without-libidn2 \
    --with-nghttp2 \
    --disable-ldap \
    --with-pic \
    --without-libssh2 \
  && make -j2 \
  && make install

RUN wget  -qO- http://nginx.org/download/nginx-1.20.2.tar.gz | tar -zxf - \
  && cd nginx-1.20.2 \
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
