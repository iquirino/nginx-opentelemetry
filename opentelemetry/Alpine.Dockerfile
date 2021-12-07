FROM iquirino91/nginx:opentelemetry AS builder

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