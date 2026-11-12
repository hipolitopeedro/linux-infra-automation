#!/usr/bin/env bash
# ==============================================================================
# Script: service-watchdog.sh
# EN: Monitors systemd services and attempts automatic restart if inactive/failed.
# PT: Monitora serviços do systemd e tenta reinício automático caso estejam parados.
# Usage: ./service-watchdog.sh <service1> [service2 ...]
# ==============================================================================

set -euo pipefail

LOG_FILE="${WATCHDOG_LOG:-/var/log/service-watchdog.log}"

log_msg() {
    local level="$1"
    local msg="$2"
    local line="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $msg"
    echo "$line"
    if [[ -w "$(dirname "$LOG_FILE")" ]]; then
        echo "$line" >> "$LOG_FILE"
    fi
}

if [[ "$#" -eq 0 ]]; then
    echo "Usage: $0 <service1> [service2 ...]"
    exit 1
fi

for SERVICE in "$@"; do
    if systemctl is-active --quiet "$SERVICE"; then
        log_msg "OK" "Service '$SERVICE' is running normally."
    else
        log_msg "WARN" "Service '$SERVICE' is DOWN! Attempting automatic restart..."
        if systemctl restart "$SERVICE"; then
            sleep 2
            if systemctl is-active --quiet "$SERVICE"; then
                log_msg "RECOVERED" "Service '$SERVICE' was successfully restarted."
            else
                log_msg "CRITICAL" "Service '$SERVICE' failed to stay active after restart."
            fi
        else
            log_msg "CRITICAL" "Failed to execute 'systemctl restart $SERVICE'."
        fi
    fi
done
