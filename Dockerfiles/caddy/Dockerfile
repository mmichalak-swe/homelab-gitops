# Require build arg
FROM caddy:2.10.2-builder-alpine AS builder
ENV GODEBUG=netdns=go

RUN xcaddy build --with github.com/caddy-dns/porkbun

FROM caddy:2.10.2-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN apk add --no-cache curl
