# HTTPS Upgrade Guide

## Overview

This upgrade adds full HTTPS support using Let's Encrypt SSL certificates and fixes Jellyfin to work with Traefik reverse proxy. All services are now accessible via secure HTTPS subdomains.

## What Changed

### 1. Traefik Configuration
- **Added HTTPS support**: Port 443 now exposed for HTTPS traffic
- **Let's Encrypt integration**: Automatic SSL certificate generation and renewal
- **HTTP to HTTPS redirect**: All HTTP traffic automatically redirected to HTTPS
- **Traefik Dashboard**: Now accessible via `https://traefik.yourdomain.com`

### 2. Jellyfin Configuration
- **Network mode changed**: From `host` to `bridge` network mode
- **IP address assigned**: 172.30.0.11 (fixed IP conflict with Traefik Socket Proxy)
- **Port exposed**: 8096 now explicitly exposed
- **Traefik labels added**: Jellyfin now accessible via `https://jellyfin.yourdomain.com`
- **User context**: Added explicit user/group configuration

### 3. All Services Updated
All services with Traefik integration now use:
- **Entrypoint**: `websecure` (HTTPS) instead of `web` (HTTP)
- **TLS**: Let's Encrypt certificate resolver enabled
- **HTTPS URLs**: All service URLs changed from `http://` to `https://`

Services updated:
- Jellyfin, Jellyseerr, Radarr, Sonarr, Prowlarr
- Decypharr, Zilean, Zurg, RDTClient
- Homarr, Dashdot, Jellystat, Pinchflat
- Traefik Dashboard

### 4. Installation Script Updates
- **Email prompt**: New prompt for Let's Encrypt email address
- **Email validation**: Validates email format before proceeding
- **Environment variable**: LETSENCRYPT_EMAIL added to .env.install
- **Completion messages**: Updated to show HTTPS URLs

### 5. Documentation Updates
- **README.md**: Already had HTTPS URLs listed
- **INSTALLATION.md**: Enhanced with Let's Encrypt email requirement
- **CLAUDE.md**: Updated Jellyfin network mode documentation
- **Setup messages**: Changed to display HTTPS URLs

## Requirements for HTTPS

To use HTTPS with Let's Encrypt, you need:

1. **Valid domain name**: Must own or control the domain
2. **DNS configured**: A/AAAA records pointing to your server
3. **Ports open**: 
   - Port 80 (HTTP) - Required for Let's Encrypt challenge
   - Port 443 (HTTPS) - For secure traffic
4. **Email address**: For Let's Encrypt certificate notifications
5. **Public IP**: Server must be accessible from the internet

## New Installation

For new installations, the setup script will:
1. Ask if you want to enable Traefik
2. If yes, prompt for your domain name
3. Prompt for your Let's Encrypt email address
4. Configure all services with HTTPS automatically

## Existing Installation Upgrade

If you have an existing installation:

1. **Backup your configuration**:
   ```bash
   cd /YOUR_INSTALL_DIR
   tar -czf backup-$(date +%Y%m%d).tar.gz config/ docker/
   ```

2. **Pull the latest changes**:
   ```bash
   cd /path/to/sailarr-installer
   git pull
   ```

3. **Add email to .env.local**:
   ```bash
   echo "LETSENCRYPT_EMAIL=your-email@example.com" >> docker/.env.local
   ```

4. **Stop services**:
   ```bash
   cd docker
   ./down.sh
   ```

5. **Update configuration**:
   - Copy new compose files
   - Ensure DOMAIN_NAME is set in .env.local
   - Ensure LETSENCRYPT_EMAIL is set in .env.local

6. **Start services**:
   ```bash
   ./up.sh
   ```

7. **Verify HTTPS**:
   - Visit `https://jellyfin.yourdomain.com`
   - Check certificate is valid (green lock icon)
   - Verify HTTP redirects to HTTPS

## Troubleshooting

### Certificate Not Generated
- **Check logs**: `docker logs traefik`
- **Verify DNS**: Ensure domain points to your server
- **Check ports**: Ports 80 and 443 must be accessible
- **Wait time**: First certificate may take a few minutes

### Jellyfin Not Accessible
- **Check container**: `docker ps | grep jellyfin`
- **Check logs**: `docker logs jellyfin`
- **Verify IP**: Should be 172.30.0.11 (not conflicting)
- **Check Traefik**: Visit Traefik dashboard to see if Jellyfin is registered

### HTTP Still Working
- This is normal! HTTP is redirected to HTTPS automatically
- Port 80 must remain open for Let's Encrypt challenges

### Certificate Renewal
- Let's Encrypt certificates are valid for 90 days
- Traefik automatically renews them before expiration
- No manual intervention needed

## Security Notes

1. **Certificate Storage**: Certificates stored in `/config/traefik-data/acme.json`
2. **Email Privacy**: Email only used for Let's Encrypt notifications
3. **Port 8096**: Still exposed for local/direct access if needed
4. **Rate Limits**: Let's Encrypt has rate limits (5 certificates per domain per week)

## Reverting to HTTP Only

If you need to revert:

1. Stop services: `./down.sh`
2. Edit compose files to change `entrypoints=websecure` back to `entrypoints=web`
3. Remove TLS certificate resolver lines
4. Remove port 443 from Traefik
5. Start services: `./up.sh`

Not recommended for production use!

## Additional Resources

- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)
- [Traefik HTTPS Documentation](https://doc.traefik.io/traefik/https/overview/)
- [TLS Challenge](https://doc.traefik.io/traefik/https/acme/#tlschallenge)
