# syntax=docker/dockerfile:1
# build-image: caddy
# build-tag-suffix: -alpine-custom-porkbun
FROM --platform=$BUILDPLATFORM caddy:2.11.4-builder-alpine@sha256:b6a94e74b72261bd536b35acdd22f3577d4e466a9550f2c8d6c8ed6413085d72 AS builder
ARG TARGETOS
ARG TARGETARCH
RUN --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOOS=$TARGETOS GOARCH=$TARGETARCH CGO_ENABLED=0 \
    xcaddy build --with github.com/caddy-dns/porkbun

# build-version-source
FROM caddy:2.11.4-alpine@sha256:5f5c8640aae01df9654968d946d8f1a56c497f1dd5c5cda4cf95ab7c14d58648
COPY --from=builder /usr/bin/caddy /usr/bin/caddy
RUN apk add --no-cache curl
