FROM caddy:2.11.4-builder-alpine@sha256:b6a94e74b72261bd536b35acdd22f3577d4e466a9550f2c8d6c8ed6413085d72 AS builder
RUN xcaddy build --with github.com/caddy-dns/porkbun

FROM caddy:2.11.4-alpine@sha256:77c07d5ebfa5be9fd6c820d2094ae662c9e7eeb9bf98346b7f639900263ee2a2
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN apk add --no-cache curl
