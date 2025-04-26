#!/system/bin/sh
# This script runs at boot to ensure rclone mounts are established.

MODPATH=${0%/*}

set -a && source ${MODPATH}/env && set +a

log -t Magisk "[rclone] service script started:"

sed -i 's/^description=\(.\{1,4\}| \)\?/description=/' "$MODULE_PROP"

run_mount() {
    rclone listremotes | sed 's/:$//' | while read -r remote; do
        rclone-mount "$remote" --daemon
        log -t Magisk "[rclone]mount: $remote => /sdcard/$remote"
    done
}


# check and delete old PID file RCLONE_WEB_PID
if [ -f "$RCLONE_WEB_PID" ]; then
    log -t Magisk "[rclone] old PID file found, deleting..."
    rm -f "$RCLONE_WEB_PID"
fi


# Wait for the system to boot completely
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 2
done
sleep 1

run_mount
sed -i 's/^description=\(.\{1,4\}| \)\?/description=🚀| /' "$MODULE_PROP"

log -t Magisk "[rclone] service script finished!"
