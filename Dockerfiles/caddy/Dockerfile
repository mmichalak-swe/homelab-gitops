FROM caddy:2.11.1-builder-alpine AS builder
RUN xcaddy build --with github.com/caddy-dns/porkbun

FROM caddy:2.11.1-alpine
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN apk add curl
