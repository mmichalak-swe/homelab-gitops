# build-image: drawio
# build-tag-suffix: -alpine-custom
# build-version-source
FROM jgraph/drawio:31.1.5@sha256:9dfa053d1fe2724f824c61eac8b8bb2e93acc8ecb23dea58b8c11028127c572c AS upstream
FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS source

# The upstream image has already built and extracted the WAR. Copy only its
# webapp into a disposable stage, then remove its server-side components.
COPY --from=upstream /usr/local/tomcat/webapps/draw/ /src/
RUN rm -rf /src/WEB-INF /src/META-INF

# Replace the public-build defaults with a device-only configuration that does
# not call draw.io's cloud integrations or external export service.
COPY PreConfig.js /src/js/PreConfig.js

FROM caddy:2.11.4-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648

LABEL maintainer="draw.io Ltd" \
      org.opencontainers.image.authors="draw.io Ltd" \
      org.opencontainers.image.url="https://www.drawio.com" \
      org.opencontainers.image.source="https://github.com/jgraph/docker-drawio"

RUN addgroup -S caddy \
    && adduser -S -D -H -s /sbin/nologin -G caddy caddy

COPY --chown=caddy:caddy Caddyfile /etc/caddy/Caddyfile
COPY --from=source --chown=caddy:caddy /src/ /srv/

USER caddy
WORKDIR /srv

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1
