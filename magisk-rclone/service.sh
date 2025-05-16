#!/system/bin/sh
# This script runs at boot to ensure rclone mounts are established.

L(){
  log -t Magisk "[rclone] $1"
}

L "service script started:"  

[ "${MODPATH}"x = ""x ] && MODPATH="${0%/*}"
L "load env: $MODPATH/env"
set -a && . "$MODPATH/env" && set +a

sed -i 's/^description=\(.\{1,4\}| \)\?/description=/' "$RCLONEPROP"

# Wait for the system to boot completely
COUNT=0
until { [ "$(getprop sys.boot_completed)" = "1" ] && [ "$(getprop init.svc.bootanim)" = "stopped" ]; } || [ $((COUNT++)) -ge 20 ]; do 
  sleep 10;
done
L "system is ready after ${COUNT}. Starting the mounting process."

/vendor/bin/rclone listremotes | sed 's/:$//' | while read -r remote; do
  L "mount $remote => /mnt/rclone-$remote => /sdcard/$remote"
  /vendor/bin/rclone-mount "$remote" --daemon
done

sed -i 's/^description=\(.\{1,4\}| \)\?/description=🚀| /' "$RCLONEPROP"

# rclone sync
if [ -f "$RCLONESYNC_CONF" ]; then
  L "load sync config from $RCLONESYNC_CONF"
  SYNC_LOG="$TMPDIR/rclone_sync.log"
  rm -f "$SYNC_LOG"
  while read -r line; do
    # 跳过空行和注释
    [ -z "$line" ] && continue
    echo "$line" | grep -qE '^\s*#' && continue
    # 逐行解析
    eval set -- $line
    options="$@"
    L "sync $@"
    nice -n 19 ionice -c3 /vendor/bin/rclone sync "$@" >> "$SYNC_LOG" 2>&1 > &
  done < "$RCLONESYNC_CONF"
  L "sync process started, log: $SYNC_LOG"
fi

L "service script finished!"
