# Sailarr - Post-Installation Configuration Guide

This guide covers the manual configuration steps required after running the automated installer.

## Table of Contents

1. [Media Server Setup](#media-server-setup)
   - [Plex Setup](#plex-setup)
   - [Jellyfin Setup](#jellyfin-setup)
2. [Overseerr Configuration](#overseerr-configuration)
   - [Connect Plex Account](#1-connect-plex-account-plex-installs)
   - [Connect Jellyfin](#1-connect-jellyfin-jellyfin-installs)
   - [Select Libraries](#2-select-libraries)
   - [Add Radarr Server](#3-add-radarr-server)
   - [Add Sonarr Server](#4-add-sonarr-server)
3. [Additional Services](#additional-services)
4. [Troubleshooting](#troubleshooting)

---

## Media Server Setup

### Plex Setup

*(Skip this section if you chose Jellyfin during installation.)*

**Access**: `http://YOUR_SERVER_IP:32400/web`

Add media libraries:
- **Movies**: `/data/media/movies`
- **TV Shows**: `/data/media/tv`
- **YouTube** (optional): `/data/media/youtube`

If you provided a Plex claim token during installation, your server should already be linked to your account. Otherwise, sign in through the Plex web UI to link it.

### Jellyfin Setup

*(Skip this section if you chose Plex during installation.)*

**Access**: `http://YOUR_SERVER_IP:8096`

On first launch, the Jellyfin setup wizard will guide you through:
1. Create an admin user and password
2. Add media libraries:
   - **Movies**: `/data/media/movies`
   - **TV Shows**: `/data/media/tv`
   - **YouTube** (optional): `/data/media/youtube`
3. Select metadata language
4. Complete setup

No Plex account or subscription is required.

---

## Overseerr Configuration

Overseerr is your media request management system that connects to your media server, Radarr, and Sonarr.

### Access Overseerr

1. Open your browser and navigate to: `http://YOUR_SERVER_IP:5055`
2. You'll be greeted with the Overseerr setup wizard

### 1. Connect Plex Account *(Plex installs)*

*(Skip to [Connect Jellyfin](#1-connect-jellyfin-jellyfin-installs) if you chose Jellyfin.)*

**Step 1: Sign in with Plex**
- Click **"Sign in with Plex"**
- Authorize Overseerr to access your Plex account
- Select your Plex server from the list

**Step 2: Server Configuration**
- **Plex Server**: Should auto-detect your server
- **Server Name**: Leave as default (usually your hostname)
- Click **Continue**

### 1. Connect Jellyfin *(Jellyfin installs)*

*(Skip this section if you chose Plex.)*

Overseerr supports Jellyfin as a media server backend. On the Overseerr setup wizard:

1. Choose **"Use Jellyfin"** (or skip the Plex sign-in prompt)
2. Enter your Jellyfin connection details:
   - **Hostname or IP**: `http://YOUR_SERVER_IP` (use container hostname `jellyfin` for internal)
   - **Port**: `8096`
   - **Username**: Your Jellyfin admin username
   - **Password**: Your Jellyfin admin password
3. Click **Sign In**
4. Select your Jellyfin libraries
5. Click **Continue**

> **Note:** Overseerr's Jellyfin integration may require a newer version of Overseerr. If you encounter issues, check the [Overseerr documentation](https://docs.overseerr.dev/) for Jellyfin setup details.

### 2. Select Libraries

**Step 3: Library Selection**
- Enable the libraries you want Overseerr to manage:
  - ☑ **Movies** (your media server Movies library)
  - ☑ **TV Shows** (your media server TV Shows library)
- Click **Continue**

### 3. Add Radarr Server

**Step 4: Radarr Configuration**

When you reach the "Add Radarr Server" screen, fill in the following:

| Field | Value | Notes |
|-------|-------|-------|
| **Default Server** | ☑ Enabled | Check this box |
| **4K Server** | ☐ Disabled | Uncheck (unless using separate 4K setup) |
| **Server Name** | `Radarr` | Any friendly name |
| **Hostname or IP Address** | `http://radarr` | Use container name (no external IP needed) |
| **Port** | `7878` | Default Radarr port |
| **Use SSL** | ☐ Disabled | Not needed for internal communication |
| **API Key** | (auto-filled below) | Automatically extracted from installation |
| **URL Base** | (leave empty) | Not needed for default setup |
| **Quality Profile** | `Recyclarr-Any` | Or choose `Recyclarr-1080p` / `Recyclarr-2160p` |
| **Root Folder** | `/data/media/movies` | Should auto-populate after test |
| **Minimum Availability** | `Released` | Recommended |
| **Tags** | (leave empty) | Optional |
| **External URL** | (leave empty) | Only needed for external access |
| **Enable Scan** | ☑ Enabled | Recommended |
| **Enable Automatic Search** | ☑ Enabled | Recommended |
| **Tag Requests** | ☑ Enabled | Adds requester info to downloads |

**Radarr API Key:**

The installer displays the API key at the end of the installation. If you need to retrieve it:

```bash
# On your server:
docker exec radarr cat /config/config.xml | grep -oP '(?<=<ApiKey>)[^<]+'
```

Or find it in the installation summary printed at the end of `./setup.sh`.

**Recommended Settings:**
- **Quality Profile**:
  - `Recyclarr-Any` - Best for most users (accepts any quality, upgrades to best)
  - `Recyclarr-1080p` - For 1080p content only
  - `Recyclarr-2160p` - For 4K content only
- **Minimum Availability**: `Released` (downloads when released, not announced)

**Before clicking "Add Server":**
1. Click **"Test"** button to verify connection
2. If successful, the Root Folder dropdown will populate
3. Select `/data/media/movies`
4. Click **"Add Server"**

### 4. Add Sonarr Server

**Step 5: Sonarr Configuration**

Click **"Add Sonarr Server"** and fill in:

| Field | Value | Notes |
|-------|-------|-------|
| **Default Server** | ☑ Enabled | Check this box |
| **4K Server** | ☐ Disabled | Uncheck (unless using separate 4K setup) |
| **Server Name** | `Sonarr` | Any friendly name |
| **Hostname or IP Address** | `http://sonarr` | Use container name |
| **Port** | `8989` | Default Sonarr port |
| **Use SSL** | ☐ Disabled | Not needed for internal communication |
| **API Key** | (auto-filled below) | Automatically extracted from installation |
| **URL Base** | (leave empty) | Not needed for default setup |
| **Series Type** | `Standard` | For regular TV shows (not anime) |
| **Quality Profile** | `Recyclarr-Any` | Or choose `Recyclarr-1080p` / `Recyclarr-2160p` |
| **Root Folder** | `/data/media/tv` | Should auto-populate after test |
| **Language Profile** | `English` | Default |
| **Tags** | (leave empty) | Optional - test connection first to load |
| **Anime Series Type** | (leave empty) | Only if you watch anime |
| **Anime Quality Profile** | (leave empty) | Only if you watch anime |
| **Anime Root Folder** | (leave empty) | Only if you watch anime |
| **Anime Language Profile** | (leave empty) | Only if you watch anime |
| **Anime Tags** | (leave empty) | Only if you watch anime |
| **Season Folders** | ☑ Enabled | Recommended - organizes by season |
| **External URL** | (leave empty) | Only needed for external access |
| **Enable Scan** | ☑ Enabled | Recommended |
| **Enable Automatic Search** | ☑ Enabled | Recommended |
| **Tag Requests** | ☑ Enabled | Adds requester info to downloads |

**Sonarr API Key:**

The installer displays the API key at the end of the installation. If you need to retrieve it:

```bash
# On your server:
docker exec sonarr cat /config/config.xml | grep -oP '(?<=<ApiKey>)[^<]+'
```

Or find it in the installation summary printed at the end of `./setup.sh`.

**Before clicking "Add Server":**
1. Click **"Test"** button to verify connection
2. If successful, the Root Folder dropdown will populate
3. Select `/data/media/tv`
4. Click **"Add Server"**

### 5. Finish Setup

**Step 6: Complete Overseerr Setup**
- Review your settings
- Click **"Finish Setup"**
- Overseerr is now ready to use!

---

## Additional Services

### Homarr Dashboard

**Access**: `http://YOUR_SERVER_IP:7575`

Homarr provides a unified dashboard for all your services. No additional configuration needed - all services are pre-configured.

### Tautulli (Plex Analytics) — *Plex installs only*

*(Tautulli is only installed when Plex is selected as your media server.)*

**Access**: `http://YOUR_SERVER_IP:8282`

**First-time setup:**
1. Click **"Sign in with Plex"**
2. Authorize Tautulli
3. Select your Plex server
4. Configuration is complete!

### Prowlarr (Indexer Manager)

**Access**: `http://YOUR_SERVER_IP:9696`

Already configured during installation with:
- ✅ Zilean indexer added
- ✅ Radarr connection configured
- ✅ Sonarr connection configured
- ✅ Automatic indexer sync enabled

No additional configuration needed unless you want to add more indexers.

---

## Service URLs Reference

| Service | URL | Purpose |
|---------|-----|---------|
| **Overseerr** | `http://YOUR_SERVER_IP:5055` | Media requests |
| **Plex** *(if Plex selected)* | `http://YOUR_SERVER_IP:32400/web` | Media server |
| **Jellyfin** *(if Jellyfin selected)* | `http://YOUR_SERVER_IP:8096` | Media server |
| **Radarr** | `http://YOUR_SERVER_IP:7878` | Movie management |
| **Sonarr** | `http://YOUR_SERVER_IP:8989` | TV show management |
| **Prowlarr** | `http://YOUR_SERVER_IP:9696` | Indexer management |
| **Homarr** | `http://YOUR_SERVER_IP:7575` | Dashboard |
| **Tautulli** *(Plex only)* | `http://YOUR_SERVER_IP:8282` | Plex analytics |
| **Zilean** | `http://YOUR_SERVER_IP:8181` | DMM indexer |

---

## Troubleshooting

### Overseerr Can't Connect to Radarr/Sonarr

**Problem**: Test button fails with connection error

**Solutions**:
1. Verify the service is running:
   ```bash
   docker ps | grep radarr
   docker ps | grep sonarr
   ```

2. Check the API key is correct:
   ```bash
   # For Radarr:
   docker exec radarr cat /config/config.xml | grep ApiKey

   # For Sonarr:
   docker exec sonarr cat /config/config.xml | grep ApiKey
   ```

3. Verify hostname is correct:
   - Use `http://radarr` (not `http://localhost` or IP address)
   - Use `http://sonarr` (not `http://localhost` or IP address)

4. Check Docker network:
   ```bash
   docker network inspect mediacenter | grep -A 5 overseerr
   ```

### Quality Profiles Not Loading

**Problem**: Quality Profile dropdown is empty after clicking Test

**Solution**: This means the API key or hostname is incorrect. Double-check both fields and click Test again.

### Root Folder Not Showing

**Problem**: Root Folder dropdown doesn't populate

**Solution**:
1. The connection test must succeed first
2. Verify the root folder exists in Radarr/Sonarr:
   - Radarr: `http://YOUR_SERVER_IP:7878/settings/mediamanagement`
   - Sonarr: `http://YOUR_SERVER_IP:8989/settings/mediamanagement`

### Can't Sign in with Plex

**Problem**: Plex authentication fails

**Solutions**:
1. Verify Plex is running:
   ```bash
   docker ps | grep plex
   ```

2. Verify Plex is accessible:
   ```bash
   curl -I http://localhost:32400/web
   ```

3. Check Plex claim token (if recently installed):
   ```bash
   docker logs plex | grep -i claim
   ```

---

## Getting Help

If you encounter issues:

1. Check service logs:
   ```bash
   docker logs overseerr
   docker logs radarr
   docker logs sonarr
   ```

2. Verify all services are healthy:
   ```bash
   docker ps --format "table {{.Names}}\t{{.Status}}"
   ```

3. Review installation logs:
   ```bash
   # Installation logs are saved in:
   /tmp/sailarr-install-*/install.log
   ```

4. Open an issue on GitHub:
   - https://github.com/JaviPege/sailarr-installer/issues

---

**Configuration complete!** 🎉

You can now start requesting media through Overseerr. Movies and TV shows will be automatically downloaded and organized by Radarr/Sonarr.
