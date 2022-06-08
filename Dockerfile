FROM alpine as builder

ENV NGINX_VERSION 1.22.0
ENV OPENTELEMETRY_VERSION v1.4.0

RUN apk update \
  && apk add --update alpine-sdk build-base cmake linux-headers libressl-dev pcre-dev zlib-dev \
      grpc-dev curl-dev protobuf-dev c-ares-dev re2-dev

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

RUN git clone --shallow-submodules --depth 1 --recurse-submodules -b ${OPENTELEMETRY_VERSION} \
  https://github.com/open-telemetry/opentelemetry-cpp.git \
  && cd opentelemetry-cpp \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/install \
    -DCMAKE_PREFIX_PATH=/install \
    -DWITH_OTLP=ON \
    -DWITH_OTLP_GRPC=ON \
    -DWITH_OTLP_HTTP=OFF \
    -DBUILD_TESTING=OFF \
    -DWITH_EXAMPLES=OFF \
    -DWITH_ABSEIL=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    .. \
  && make -j2 \
  && make install

RUN git clone https://github.com/open-telemetry/opentelemetry-cpp-contrib.git \
  && cd opentelemetry-cpp-contrib/instrumentation/nginx \
  && mkdir build \
  && cd build \
  && cmake -DCMAKE_BUILD_TYPE=Release \
    -DNGINX_BIN=/etc/nginx/nginx \
    -DCMAKE_PREFIX_PATH=/install \
    -DCMAKE_INSTALL_PREFIX=/etc/nginx/modules \
    -DCURL_LIBRARY=/usr/lib/libcurl.so.4 \
    .. \
  && make -j2 \
  && make install


FROM alpine

COPY --from=builder /etc/passwd /etc/group /etc/
RUN true
COPY --from=builder /etc/nginx /etc/nginx
RUN true
COPY --from=builder /usr/local/lib /usr/local/lib
RUN true
COPY --from=builder /usr/lib /usr/lib
RUN true

RUN mkdir -p /var/log/nginx/ && \
    echo -n > /var/log/nginx/access.log && \
    echo -n > /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

STOPSIGNAL SIGQUIT
EXPOSE 80

CMD ["/etc/nginx/nginx", "-g", "daemon off;"]
