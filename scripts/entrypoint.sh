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

# Start server: listen on UDP 53 and TCP 8000, forward to 127.0.0.1:8000
exec dnstt-server -udp :53 -tcp :8000 -privkey-file /etc/dnstt/server.key "$DOMAIN" 127.0.0.1:8000
