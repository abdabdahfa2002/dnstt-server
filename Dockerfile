# Dockerfile for dnstt server
FROM golang:1.24-alpine AS builder

WORKDIR /build

# Install git to fetch source
RUN apk add --no-cache git

# Fetch dnstt source
RUN git clone https://www.bamsoftware.com/git/dnstt.git .

# Build dnstt-server
RUN cd dnstt-server && GOOS=linux GOARCH=amd64 go build -o /dnstt-server .

# Final minimal image
FROM alpine:3.20

RUN apk add --no-cache ca-certificates

COPY --from=builder /dnstt-server /usr/local/bin/dnstt-server
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create directory for keys
RUN mkdir -p /etc/dnstt

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["-udp", ":53", "-tcp", ":8000", "-privkey-file", "/etc/dnstt/server.key", "t.example.com", "127.0.0.1:8000"]

# Health check: try a DNS query via UDP to localhost:53 (simple)
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD dig @127.0.0.1 -p 53 example.com || exit 1
