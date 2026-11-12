#!/usr/bin/env bash
# ==============================================================================
# Script: system-health-audit.sh
# EN: Collects system metrics, disk usage alerts, open ports, and SSH security events.
# PT: Coleta métricas do sistema, alertas de disco, portas abertas e eventos SSH.
# ==============================================================================

set -euo pipefail

DISK_THRESHOLD="${1:-80}"

echo "============================================================"
echo "   LINUX SERVER HEALTH & SECURITY AUDIT"
echo "   Timestamp : $(date '+%Y-%m-%d %H:%M:%S %Z')"
echo "   Hostname  : $(hostname -f 2>/dev/null || hostname)"
echo "============================================================"

echo -e "\n[1] SYSTEM & KERNEL SUMMARY"
echo "    OS Release : $(grep -E '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '\"' || uname -s)"
echo "    Kernel     : $(uname -r)"
echo "    Uptime     : $(uptime -p 2>/dev/null || uptime)"
echo "    Load Avg   : $(awk '{print $1, $2, $3}' /proc/loadavg)"

echo -e "\n[2] MEMORY UTILIZATION"
free -h | awk 'NR==1{print "    " $0} NR==2{printf "    %-10s Total: %-8s Used: %-8s Free: %-8s Available: %-8s\n", $1, $2, $3, $4, $7}'

echo -e "\n[3] FILESYSTEM USAGE (Alert Threshold: ${DISK_THRESHOLD}%)"
df -hP -x tmpfs -x devtmpfs | awk -v thresh="$DISK_THRESHOLD" '
NR==1 { printf "    %-25s %-8s %-8s %-8s %-6s %-s\n", "Filesystem", "Size", "Used", "Avail", "Use%", "Mounted on" }
NR>1 {
    use_pct = $5; gsub(/%/, "", use_pct);
    status = (use_pct + 0 >= thresh + 0) ? "[ALERT]" : "[OK]";
    printf "    %-25s %-8s %-8s %-8s %-6s %-15s %s\n", $1, $2, $3, $4, $5, $6, status
}'

echo -e "\n[4] TOP 5 CPU-CONSUMING PROCESSES"
ps -eo pid,user,%cpu,%mem,comm --sort=-%cpu | head -n 6 | sed 's/^/    /'

echo -e "\n[5] LISTENING NETWORK PORTS (TCP/UDP)"
if command -v ss >/dev/null 2>&1; then
    ss -tulnp | head -n 15 | sed 's/^/    /'
elif command -v netstat >/dev/null 2>&1; then
    netstat -tulnp | head -n 15 | sed 's/^/    /'
fi

echo -e "\n[6] RECENT FAILED SSH LOGIN ATTEMPTS"
AUTH_LOG=""
[[ -f /var/log/auth.log ]] && AUTH_LOG="/var/log/auth.log"
[[ -f /var/log/secure ]] && AUTH_LOG="/var/log/secure"

if [[ -n "$AUTH_LOG" && -r "$AUTH_LOG" ]]; then
    grep -i "Failed password" "$AUTH_LOG" | tail -n 5 | sed 's/^/    /' || echo "    No failed password events found."
else
    echo "    Auth log not readable (run with sudo for security audit logs)."
fi

echo "============================================================"
