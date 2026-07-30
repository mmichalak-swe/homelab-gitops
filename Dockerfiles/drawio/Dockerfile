# build-image: drawio
# build-tag-suffix: -alpine-custom

FROM alpine:3.24.1@sha256:28bd5fe8b56d1bd048e5babf5b10710ebe0bae67db86916198a6eec434943f8b AS alpine-base

# build-version-source
FROM jgraph/drawio:31.1.5@sha256:9dfa053d1fe2724f824c61eac8b8bb2e93acc8ecb23dea58b8c11028127c572c AS upstream

FROM alpine-base AS source

# The upstream image has already built and extracted the WAR. Copy only its
# webapp into a disposable stage, then remove its server-side components.
COPY --from=upstream /usr/local/tomcat/webapps/draw/ /src/
RUN rm -rf /src/WEB-INF /src/META-INF

# Replace the public-build defaults with a device-only configuration that does
# not call draw.io's cloud integrations or external export service.
COPY PreConfig.js /src/js/PreConfig.js

FROM caddy:2.11.4-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648 AS caddy-source

# A normal copy does not preserve Caddy's CAP_NET_BIND_SERVICE extended
# attribute. Verify that the capability-free binary is safe to copy into the
# final image, which listens on unprivileged port 8080.
RUN cp /usr/bin/caddy /caddy \
    && test -z "$(getcap /caddy)"

FROM alpine-base AS runtime

LABEL maintainer="mmichalak-swe" \
      org.opencontainers.image.authors="mmichalak-swe" \
      org.opencontainers.image.url="https://github.com/mmichalak-swe/homelab-gitops" \
      org.opencontainers.image.source="https://github.com/jgraph/docker-drawio"

RUN apk add --no-cache ca-certificates mailcap \
    && addgroup -S caddy \
    && adduser -S -D -H -s /sbin/nologin -G caddy caddy

COPY --from=caddy-source --chown=root:root --chmod=0755 /caddy /usr/bin/caddy
COPY --chown=caddy:caddy Caddyfile /etc/caddy/Caddyfile
COPY --from=source --chown=caddy:caddy /src/ /srv/

ENV XDG_CONFIG_HOME=/tmp/caddy-config \
    XDG_DATA_HOME=/tmp/caddy-data

USER caddy
WORKDIR /srv

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -q -O /dev/null http://127.0.0.1:8080/healthz || exit 1

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]
