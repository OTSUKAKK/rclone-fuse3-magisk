#!/system/bin/sh
# This script runs at boot to ensure rclone mounts are established.


log -t Magisk "[rclone] service script started:"

set -a && source "./env" && set +a
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

sleep 1

/vendor/bin/rclone listremotes | sed 's/:$//' | while read -r remote; do
  /vendor/bin/rclone-mount "$remote" --daemon
  log -t Magisk "[rclone]mount: $remote => /sdcard/$remote"
done

sed -i 's/^description=\(.\{1,4\}| \)\?/description=🚀| /' "$MODULE_PROP"
log -t Magisk "[rclone] service script finished!"
