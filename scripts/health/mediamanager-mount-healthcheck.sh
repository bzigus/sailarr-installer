#!/bin/bash
# MediaManager Mount Healthcheck Script
# Verifies that MediaManager and Decypharr can access the rclone mount
# If not, restarts the containers

# Detect installation directory from .env.local or use default
if [ -f "/mediacenter/docker/.env.local" ]; then
    ROOT_DIR=$(grep "^ROOT_DIR=" /mediacenter/docker/.env.local | cut -d'=' -f2)
elif [ -f "/opt/sailarr/docker/.env.local" ]; then
    ROOT_DIR=$(grep "^ROOT_DIR=" /opt/sailarr/docker/.env.local | cut -d'=' -f2)
else
    ROOT_DIR="/mediacenter"  # Default fallback
fi

LOG_FILE="${ROOT_DIR}/logs/mediamanager-mount-healthcheck.log"
TEST_FILE="${ROOT_DIR}/data/realdebrid-zurg/torrents/.healthcheck_test.txt"
DOCKER_COMPOSE_DIR="${ROOT_DIR}/docker"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_container() {
    local container=$1
    if docker exec "$container" test -f "$TEST_FILE" 2>/dev/null; then
        return 0  # Success
    else
        return 1  # Failed
    fi
}

restart_container() {
    local container=$1
    log "RESTART: $container cannot access mount, restarting..."
    cd "$DOCKER_COMPOSE_DIR" || exit 1
    ./restart.sh "$container" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ]; then
        log "SUCCESS: $container restarted successfully"
    else
        log "ERROR: Failed to restart $container"
    fi
}

# Check MediaManager
if ! check_container "mediamanager"; then
    log "FAILED: MediaManager cannot access $TEST_FILE"
    restart_container "mediamanager"
else
    log "OK: MediaManager mount check passed"
fi

# Check Decypharr
if ! check_container "decypharr"; then
    log "FAILED: Decypharr cannot access $TEST_FILE"
    restart_container "decypharr"
else
    log "OK: Decypharr mount check passed"
fi
