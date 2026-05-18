FROM caddy:2.11.3-builder-alpine@sha256:52575959b1eeee9900869325a953d71e4c521ab9102dd5cce07d429ea8246b85 AS builder
RUN xcaddy build --with github.com/caddy-dns/porkbun

FROM caddy:2.11.3-alpine@sha256:bb56e6200ec26a67f04be90255993dc390c9815967f67f24b4ca6466e88de64b
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN apk add --no-cache curl
