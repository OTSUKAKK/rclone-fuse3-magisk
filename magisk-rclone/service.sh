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
COUNT=0
until { [ "$(getprop sys.boot_completed)" = "1" ] && [ "$(getprop init.svc.bootanim)" = "stopped" ]; } || [ $((COUNT++)) -ge 20 ]; do 
  sleep 10;
done
log -t Magisk "[rclone] system is ready after ${COUNT}. Starting the mounting process."

/vendor/bin/rclone listremotes | sed 's/:$//' | while read -r remote; do
  log -t Magisk "[rclone] mount: [$remote] => /mnt/rclone-$remote => /sdcard/$remote"
  /vendor/bin/rclone-mount "$remote" --daemon
done

sed -i 's/^description=\(.\{1,4\}| \)\?/description=🚀| /' "$MODULE_PROP"
log -t Magisk "[rclone] service script finished!"
