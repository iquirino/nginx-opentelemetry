FROM iquirino91/nginx

ENV OPENTELEMETRY_VERSION v1.1.0
ENV OPENTELEMETRY_VERSION_CPP v0.1.0

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

RUN mkdir -p /var/log/nginx/ && \
    echo -n > /var/log/nginx/access.log && \
    echo -n > /var/log/nginx/error.log && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log

STOPSIGNAL SIGQUIT
EXPOSE 80

CMD ["/etc/nginx/nginx", "-g", "daemon off;"]