#!/bin/bash
# MediaCenter - Recyclarr Sync Script
# NOTE: This script is NOT compatible with MediaManager
# MediaManager has its own built-in quality profile and scoring system
# This script is kept for backwards compatibility if switching back to Radarr/Sonarr

echo "================================================================"
echo "NOTICE: Recyclarr is not compatible with MediaManager"
echo "================================================================"
echo ""
echo "MediaManager uses its own quality scoring system configured in"
echo "the config.toml file under [indexers.title_scoring_rules]"
echo ""
echo "If you need to switch back to Radarr/Sonarr:"
echo "  1. Edit docker/docker-compose.yml"
echo "  2. Comment out mediamanager.yml"
echo "  3. Uncomment radarr.yml and sonarr.yml"
echo "  4. Restore config/recyclarr.yml.legacy to config/recyclarr.yml"
echo "  5. Run docker compose up -d"
echo "  6. Then you can use this script again"
echo ""
exit 0

# Legacy code below - kept for reference
# =====================================================

set -e

# Load environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if docker is available
if ! command -v docker &> /dev/null; then
    echo "ERROR: Docker is not installed or not in PATH"
    exit 1
fi

# Get API keys from Radarr and Sonarr
echo "Fetching API keys from Radarr and Sonarr..."

RADARR_API_KEY=$(docker exec radarr cat /config/config.xml 2>/dev/null | grep -oP '(?<=<ApiKey>)[^<]+' || echo "")
SONARR_API_KEY=$(docker exec sonarr cat /config/config.xml 2>/dev/null | grep -oP '(?<=<ApiKey>)[^<]+' || echo "")

if [ -z "$RADARR_API_KEY" ]; then
    echo "ERROR: Could not fetch Radarr API key. Is Radarr running?"
    exit 1
fi

if [ -z "$SONARR_API_KEY" ]; then
    echo "ERROR: Could not fetch Sonarr API key. Is Sonarr running?"
    exit 1
fi

echo "✓ API keys retrieved"
echo ""
echo "Running Recyclarr sync..."
echo "This will:"
echo "  • Create/update quality profiles (Recyclarr-1080p, Recyclarr-2160p, Recyclarr-Any)"
echo "  • Configure custom formats from TRaSH Guides"
echo "  • Set up media naming conventions for Jellyfin"
echo ""

# Create temporary config with API keys injected
TEMP_CONFIG="/tmp/recyclarr-temp-$$.yml"
awk -v radarr_key="${RADARR_API_KEY}" -v sonarr_key="${SONARR_API_KEY}" '
    /^radarr:/ {in_radarr=1; in_sonarr=0}
    /^sonarr:/ {in_radarr=0; in_sonarr=1}
    /api_key:$/ {
        if (in_radarr) {print "    api_key: " radarr_key; next}
        if (in_sonarr) {print "    api_key: " sonarr_key; next}
    }
    {print}
' "${SCRIPT_DIR}/../config/recyclarr.yml.legacy" > "$TEMP_CONFIG"

# Run Recyclarr with Docker
docker run --rm \
    --network mediacenter \
    -v "${TEMP_CONFIG}:/config/recyclarr.yml:ro" \
    ghcr.io/recyclarr/recyclarr:latest \
    sync

# Cleanup
rm -f "$TEMP_CONFIG"

echo ""
echo "✓ Recyclarr sync completed successfully!"
echo ""
echo "Quality profiles created:"
echo "  • Recyclarr-1080p - For 1080p content with upgrades to Remux"
echo "  • Recyclarr-2160p - For 4K content with upgrades to Remux"
echo "  • Recyclarr-Any - Accepts any quality, upgrades to best available"
echo ""
echo "Naming conventions configured for Jellyfin compatibility"
