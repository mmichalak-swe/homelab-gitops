FROM caddy:2.11.3-builder-alpine@sha256:7d2315853f99b425d0daa6bcad826e8b0d65b4af1f70fcaeb6b152157d81771d AS builder
RUN xcaddy build --with github.com/caddy-dns/porkbun

FROM caddy:2.11.3-alpine@sha256:86deaf5e3d3408a6ccec08fbb79989783dd26e206ae10bcf78a801dc8c9ab794
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN apk add --no-cache curl
