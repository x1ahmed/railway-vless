FROM alpine:latest

ADD entrypoint.sh /opt/entrypoint.sh

RUN apk add --no-cache curl busybox unzip && \
    chmod +x /opt/entrypoint.sh

ENTRYPOINT ["sh", "/opt/entrypoint.sh"]
