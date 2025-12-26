# Sailarr - Post-Installation Configuration Guide

This guide covers the manual configuration steps required after running the automated installer.

## Table of Contents

1. [Jellyseerr Configuration](#jellyseerr-configuration)
   - [Connect Jellyfin Account](#1-connect-jellyfin-account)
   - [Select Libraries](#2-select-libraries)
   - [Configure MediaManager](#3-configure-mediamanager)
2. [Additional Services](#additional-services)
3. [Troubleshooting](#troubleshooting)

---

## Jellyseerr Configuration

Jellyseerr is your media request management system that connects to Jellyfin and MediaManager.

### Access Jellyseerr

1. Open your browser and navigate to: `http://YOUR_SERVER_IP:5055`
2. You'll be greeted with the Jellyseerr setup wizard

### 1. Connect Jellyfin Account

**Step 1: Sign in with Jellyfin**
- Click **"Use Jellyfin Account"**
- Enter your Jellyfin server URL: `http://jellyfin:8096` (or `http://YOUR_SERVER_IP:8096` for external access)
- Enter your Jellyfin admin username and password
- Click **Sign In**

**Step 2: Server Configuration**
- **Jellyfin Server**: Should auto-detect your server
- **Server Name**: Leave as default (usually your hostname)
- Click **Continue**

### 2. Select Libraries

**Step 3: Library Selection**
- Enable the libraries you want Jellyseerr to manage:
  - ☑ **Movies** (your Jellyfin Movies library)
  - ☑ **TV Shows** (your Jellyfin TV Shows library)
- Click **Continue**

### 3. Configure MediaManager

**Step 4: MediaManager Setup**

MediaManager is the unified media management system that replaces Radarr and Sonarr. It handles both movies and TV shows in a single interface.

**Access MediaManager:**
- URL: `http://YOUR_SERVER_IP:8000`
- First time? You'll need to create an admin account

**Initial Configuration:**

1. **Create Admin Account** (first login only)
   - Use the email configured during installation (from `.env.install`)
   - Set a secure password
   - This account will have full administrative access

2. **Configure Torrent Client**
   - Navigate to Settings → Torrent Clients
   - Decypharr is already pre-configured, verify the settings:
     - Type: `qBittorrent`
     - Host: `http://decypharr`
     - Port: `8283`
     - Username: `http://mediamanager:8000`
     - Password: Your MediaManager API key (auto-configured)

3. **Configure Indexers**
   - Navigate to Settings → Indexers
   - Prowlarr is already configured with:
     - URL: `http://prowlarr:9696`
     - API Key: (auto-configured during installation)
   - Indexers include: Zilean, Torrentio, 1337x, TPB, YTS, EZTV

4. **Configure Libraries**
   - Navigate to Settings → Libraries
   - Default libraries are pre-configured:
     - **Movies**: `/data/media/movies`
     - **TV Shows**: `/data/media/tv`
   - You can add custom libraries if needed

5. **Configure Quality & Scoring**
   - Navigate to Settings → Indexers → Scoring Rules
   - Default rules are configured:
     - Prefer H.265/HEVC codec
     - Avoid CAM/TS releases
     - Reject nuked releases
   - Customize as needed for your preferences

**Integration with Jellyseerr:**

Jellyseerr doesn't directly integrate with MediaManager yet. For now, use MediaManager's web interface to:
1. Search for movies/TV shows
2. Add them to your library
3. Monitor downloads and imports

MediaManager will automatically:
- Search indexers via Prowlarr
- Download torrents via Decypharr to Real-Debrid
- Import media to `/data/media/movies` or `/data/media/tv`
- Trigger Jellyfin library updates via Autoscan

### 4. Finish Setup

**Step 5: Complete Configuration**
- Jellyseerr is configured with Jellyfin
- MediaManager is configured with indexers and download client
- You're ready to start adding media!

**Note on Jellyseerr**: 
Since MediaManager is a newer service, Jellyseerr integration is not yet available. You can still use Jellyseerr for managing requests, but you'll need to manually add content in MediaManager. Alternatively, use MediaManager directly for searching and adding content.

---

## Additional Services

### Homarr Dashboard

**Access**: `http://YOUR_SERVER_IP:7575`

Homarr provides a unified dashboard for all your services. No additional configuration needed - all services are pre-configured.

### Jellystat (Jellyfin Analytics)

**Access**: `http://YOUR_SERVER_IP:3210`

**First-time setup:**
1. Create an admin account
2. Connect to your Jellyfin server
3. Configuration is complete!

### Prowlarr (Indexer Manager)

**Access**: `http://YOUR_SERVER_IP:9696`

Already configured during installation with:
- ✅ Zilean indexer added
- ✅ MediaManager integration configured via API
- ✅ Automatic indexer sync enabled

No additional configuration needed unless you want to add more indexers.

---

## Service URLs Reference

| Service | URL | Purpose |
|---------|-----|---------|
| **Jellyseerr** | `http://YOUR_SERVER_IP:5055` | Media requests |
| **Jellyfin** | `http://YOUR_SERVER_IP:8096/web` | Media server |
| **MediaManager** | `http://YOUR_SERVER_IP:8000` | Media management |
| **Prowlarr** | `http://YOUR_SERVER_IP:9696` | Indexer management |
| **Homarr** | `http://YOUR_SERVER_IP:7575` | Dashboard |
| **Jellystat** | `http://YOUR_SERVER_IP:3210` | Jellyfin analytics |
| **Zilean** | `http://YOUR_SERVER_IP:8182` | DMM indexer |

---

## Troubleshooting

### Jellyseerr Can't Connect to Services

**Problem**: Test button fails with connection error

**Solutions**:
1. Verify the service is running:
   ```bash
   docker ps | grep mediamanager
   docker ps | grep prowlarr
   ```

2. Check MediaManager is accessible:
   ```bash
   curl http://localhost:8000/health
   ```

3. Verify hostname is correct:
   - Use `http://mediamanager` for MediaManager (not `http://localhost` or IP address)
   - Use container names for internal communication

4. Check Docker network:
   ```bash
   docker network inspect mediacenter | grep -A 5 jellyseerr
   ```

### Quality Profiles Not Loading

**Problem**: Quality Profile dropdown is empty after clicking Test

**Solution**: This means the API key or hostname is incorrect. Double-check both fields and click Test again.

### Root Folder Not Showing

**Problem**: Root Folder dropdown doesn't populate

**Solution**:
1. The connection test must succeed first
2. Verify the root folder exists in MediaManager:
   - MediaManager: `http://YOUR_SERVER_IP:8000/settings/libraries`

### Can't Sign in with Jellyfin

**Problem**: Jellyfin authentication fails

**Solutions**:
1. Verify Jellyfin is running:
   ```bash
   docker ps | grep jellyfin
   ```

2. Verify Jellyfin is accessible:
   ```bash
   curl -I http://localhost:8096
   ```

3. Check Jellyfin logs for errors:
   ```bash
   docker logs jellyfin | tail -50
   ```

---

## Getting Help

If you encounter issues:

1. Check service logs:
   ```bash
   docker logs jellyseerr
   docker logs mediamanager
   docker logs prowlarr
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

You can now start managing your media library through MediaManager. Content will be automatically downloaded and organized, then available in Jellyfin.
