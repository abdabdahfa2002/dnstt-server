#!/bin/sh
set -e

# Generate keys if missing
if [ ! -f /etc/dnstt/server.key ] || [ ! -f /etc/dnstt/server.pub ]; then
  echo "Generating dnstt server keys..."
  dnstt-server -gen-key -privkey-file /etc/dnstt/server.key -pubkey-file /etc/dnstt/server.pub
fi

# Print public key for user (appears in logs)
echo "Server public key (copy to client):"
cat /etc/dnstt/server.pub
echo

# Domain from environment
: "${DOMAIN?environment variable DOMAIN is required (e.g., t.example.com)}"

# Start server: listen on TCP port provided by Koyeb ($PORT or default 8000)
: "${PORT:=8000}"
echo "Starting dnstt-server on TCP port $PORT for domain $DOMAIN..."
exec dnstt-server -tcp ":$PORT" -privkey-file /etc/dnstt/server.key "$DOMAIN" 127.0.0.1:8000
