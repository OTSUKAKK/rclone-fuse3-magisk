#!/system/bin/sh
# This script runs at boot to ensure rclone mounts are established.

log -t Magisk "[rclone] service script started:"

[ "${MODPATH}"x = ""x ] && MODPATH="${0%/*}"
log -t Magisk "[rclone] load env: $MODPATH/env"
set -a && source "$MODPATH/env" && set +a

sed -i 's/^description=\(.\{1,4\}| \)\?/description=/' "$MODULE_PROP"

# check and delete old PID file RCLONE_WEB_PID
if [ -f "$RCLONE_WEB_PID" ]; then
    log -t Magisk "[rclone] remove old PID file found"
    rm -f "$RCLONE_WEB_PID"
fi

# Wait for the system to boot completely
until [ "$(getprop sys.boot_completed)" -eq 1 ]; do
    sleep 2
done

/vendor/bin/rclone listremotes | sed 's/:$//' | while read -r remote; do
  /vendor/bin/rclone-mount "$remote" --daemon
  log -t Magisk "[rclone]mount: $remote => /sdcard/$remote"
done

sed -i 's/^description=\(.\{1,4\}| \)\?/description=🚀| /' "$MODULE_PROP"
log -t Magisk "[rclone] service script finished!"
