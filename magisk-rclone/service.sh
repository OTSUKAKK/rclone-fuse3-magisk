#!/system/bin/sh
# This script runs at boot to ensure rclone mounts are established.

log -t Magisk "[rclone] service script started:"

[ "${MODPATH}"x = ""x ] && MODPATH="${0%/*}"
log -t Magisk "[rclone] load env: $MODPATH/env"
set -a && . "$MODPATH/env" && set +a

sed -i 's/^description=\(.\{1,4\}| \)\?/description=/' "$RCLONEPROP"

# Wait for the system to boot completely
COUNT=0
until { [ "$(getprop sys.boot_completed)" = "1" ] && [ "$(getprop init.svc.bootanim)" = "stopped" ]; } || [ $((COUNT++)) -ge 20 ]; do 
  sleep 10;
done
log -t Magisk "[rclone] system is ready after ${COUNT}. Starting the mounting process."

/vendor/bin/rclone listremotes | sed 's/:$//' | while read -r remote; do
  log -t Magisk "[rclone] mount: [$remote] => /mnt/rclone-$remote => /sdcard/$remote"
  /vendor/bin/rclone-mount "$remote" --daemon --syslog
done

sed -i 's/^description=\(.\{1,4\}| \)\?/description=🚀| /' "$RCLONEPROP"
log -t Magisk "[rclone] service script finished!"
