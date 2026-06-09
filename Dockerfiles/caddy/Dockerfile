FROM caddy:2.11.4-builder-alpine@sha256:0ff10d4b83af453e5526b1c3cd7ae43396832aa8a2a55311d624f6812b33767d AS builder
RUN xcaddy build --with github.com/caddy-dns/porkbun

FROM caddy:2.11.3-alpine@sha256:86deaf5e3d3408a6ccec08fbb79989783dd26e206ae10bcf78a801dc8c9ab794
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN apk add --no-cache curl
