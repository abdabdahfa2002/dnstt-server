# DNSTT Server on Fly.io

Deploy a DNS tunnel server (DNSTT) on Fly.io with minimal configuration.

## Overview

- **DNSTT** is a DNS tunnel that can use DoH/DoT, and plain UDP.
- This repository provides a Docker-based deployment for Fly.io.
- Server listens on:
  - UDP port 53 (plain DNS)
  - TCP port 8000 (DoT or direct TCP)

## Prerequisites

1. A [Fly.io](https://fly.io) account (free tier available).
2. A domain name you control to delegate a subdomain to this server.

## Deployment Steps

### 1. Create a DNS subdomain
Choose a short subdomain, e.g., `t.example.com`. Add these DNS records at your registrar:

| Type | Name              | Value      |
|------|-------------------|------------|
| A    | t.example.com     | *Fly IP*   |
| NS   | ns.t.example.com  | *Fly IP*   |

After app is deployed, you can find its IP in Fly.io dashboard.

### 2. Update configuration
Edit `fly.toml` if you need:
- `primary_region` (default: ams)
- `app` name (must match your app)

The domain name used by the server is set in the `CMD` in Dockerfile: `t.example.com`. Change it to your chosen subdomain.

Also, the local port the server forwards to is `127.0.0.1:8000` (adjustable by changing CMD last argument).

### 3. Launch App on Fly.io

In Fly.io dashboard:
- Click **Launch App**
- Choose **Launch from GitHub**
- Select your repository (or connect if not)
- App name: `dnstt-server`
- Region: as you prefer
- Let it build from the Dockerfile

Alternatively, use CLI:
```bash
fly launch --name dnstt-server --region ams --no-deploy
fly deploy
```

### 4. Get the server's public key

Once the app is running, view logs:
```bash
fly logs
```
The entrypoint prints the public key to stdout. Copy that key.

Alternatively, exec into the machine:
```bash
fly ssh
cat /etc/dnstt/server.pub
```

### 5. Configure the client (Termux)

On your Termux device:

1. Ensure `dnstt-client` is installed (see separate client setup script).
2. Create `~/.dnstt/client.conf`:

```
resolver=172.21.100.1:53
domain=t.example.com
local_port=7000
pubkey_file=/data/data/com.termux/files/home/.dnstt/server.pub
transport=udp
```

Replace `t.example.com` with your actual subdomain.

3. Copy the server public key you obtained earlier to `~/.dnstt/server.pub`.

### 6. Run the client

```bash
dnstt-client-run
```

It will listen on `127.0.0.1:7000`. Applications can connect to that port as a SOCKS/HTTP proxy depending on your setup.

### 7. Test

```bash
curl -I https://ifconfig.me
```

If you see normal HTTP headers, the tunnel works.

## Troubleshooting

- **DNS not delegating**: Ensure NS record points to the Fly app IP and propagation complete.
- **UDP blocked**: On client config, switch `transport=udp` to `transport=doh` and set `doh_url` to a public resolver (Cloudflare: `https://1.1.1.1/dns-query`). DNSTT supports DoH even if your network blocks raw UDP.
- **Port conflicts**: Fly allows binding to 53 and 8000. If you change ports, update both Dockerfile CMD and client configuration accordingly.
- **Health check**: The `/` health check is not actually served; dnstt-server is not HTTP. You may need to adjust health checks to TCP port 8000 in Fly.toml if defaults fail. Modify `[service]` or disable health checks if necessary.

## Notes

- DNSTT does not provide a full TUN device; it's a TCP-to-DNS tunnel. To use as a full internet proxy, run a SOCKS or HTTP proxy on the server and have the client connect to the tunnel's local port.
- For low-latency and reliability, consider running a lightweight proxy on the server (like `3proxy` or `ncat` for simple forwarding).
- Security: The tunnel uses end-to-end encryption via Noise protocol. Keep private keys secure.

## File Structure

- `Dockerfile` – Builds dnstt-server from source.
- `fly.toml` – Fly.io configuration.
- `scripts/entrypoint.sh` – Initializes keys and launches server.
- This README.

---

**End.**
