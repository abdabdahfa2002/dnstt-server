# Dockerfile for dnstt server
FROM golang:1.24-alpine AS builder

WORKDIR /build
RUN apk add --no-cache git
RUN git clone https://www.bamsoftware.com/git/dnstt.git .
RUN cd dnstt-server && CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags="-s -w" -o /dnstt-server .

FROM alpine:3.20
RUN apk add --no-cache ca-certificates bind-tools  # bind-tools for dig healthcheck
COPY --from=builder /dnstt-server /usr/local/bin/dnstt-server
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /etc/dnstt

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD dig @127.0.0.1 -p 53 example.com >/dev/null || exit 1

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
