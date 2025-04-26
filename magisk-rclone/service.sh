#!/system/bin/sh
# This script runs at boot to ensure rclone mounts are established.

MODPATH=${0%/*}
source ${MODPATH}/env

# check and delete old PID file RCLONE_WEB_PID
if [ -f "$RCLONE_WEB_PID" ]; then
    log -t Magisk "[rclone] old PID file found, deleting..."
    rm -f "$RCLONE_WEB_PID"
fi

log -t Magisk "[rclone] service script started:"

# Wait for the system to boot completely
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 2
done

sleep 1

log -t Magisk "[rclone] service script finished!"