# syntax=docker/dockerfile:1
# build-image: caddy
# build-tag-suffix: -alpine-custom-porkbun
FROM --platform=$BUILDPLATFORM caddy:2.11.4-builder-alpine@sha256:2b9f32cbba6045e79212bb253f595588d20be8f7d1edf61582c519e124e0d2d8 AS builder
ARG TARGETOS
ARG TARGETARCH
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 \
    xcaddy build --with github.com/caddy-dns/porkbun

# build-version-source
FROM caddy:2.11.4-alpine@sha256:de23def33b17fb5d1290b0f6c2add1d70780e52341896c00a4c8a2a2fe9d355e
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN apk add --no-cache curl
