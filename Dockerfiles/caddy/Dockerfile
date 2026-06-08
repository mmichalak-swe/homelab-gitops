FROM caddy:2.11.3-builder-alpine@sha256:3eae6b351ecdb05da6d16e341261a457692d344a435764c5ece7a60cf03a23f3 AS builder
RUN xcaddy build --with github.com/caddy-dns/porkbun

FROM caddy:2.11.3-alpine@sha256:86deaf5e3d3408a6ccec08fbb79989783dd26e206ae10bcf78a801dc8c9ab794
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN apk add --no-cache curl
