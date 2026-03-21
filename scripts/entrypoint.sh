#!/bin/sh
# Container entrypoint script for dnstt-server on Fly.io
set -e

# Generate keys if not present
if [ ! -f /etc/dnstt/server.key ] || [ ! -f /etc/dnstt/server.pub ]; then
  echo "Generating dnstt server keys..."
  dnstt-server -gen-key -privkey-file /etc/dnstt/server.key -pubkey-file /etc/dnstt/server.pub
fi

# Print location of public key for user to copy
echo "Public key (copy to client):"
cat /etc/dnstt/server.pub
echo

# Start server
exec "$@"  # runs the CMD from Dockerfile
