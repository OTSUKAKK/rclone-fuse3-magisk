#!/system/bin/sh

MODPATH=${MODPATH:-/data/adb/modules/rclone}

echo "Loading Environment Variables from:"
echo "  * $MODPATH/env"
set -a && source "$MODPATH/env" && set +a
echo "  * $RCLONE_CONFIG_DIR/env"

# Check if RCLONE_WEB_PID exists and stop the running process
if [ -f "$RCLONE_WEB_PID" ]; then
    PID=$(cat "$RCLONE_WEB_PID")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "RClone web process is already running with PID: $PID. Stopping it..."
        kill "$PID"
        rm -f "$RCLONE_WEB_PID"
        echo "RClone web process stopped."
        exit 0
    else
        echo "Stale PID file found. Removing it."
        rm -f "$RCLONE_WEB_PID"
    fi
fi

if [[ "${RCLONE_RC_ADDR}" == :* ]]; then
    URL="http://localhost${RCLONE_RC_ADDR}"
else
    URL=${RCLONE_RC_ADDR}
fi

echo "RClone web GUI will start ${URL}"
echo "Open the following the URL in your browser to access the web GUI"
echo "浏览器访问: ${URL} 进行配置"


# Start the RClone web process and save the PID
# Check if htpasswd file exists
if [ -f "$RCLONE_CONFIG_DIR/htpasswd" ]; then
    echo "htpasswd file found, using it for authentication"
    /vendor/bin/rclone-web --rc-htpasswd="$RCLONE_CONFIG_DIR/htpasswd" &
    echo $! > "$RCLONE_WEB_PID"
    echo "RClone web process started with PID($!)"
else
    echo "$RCLONE_CONFIG_DIR/htpasswd file not found, using no auth"
    /vendor/bin/rclone-web &
    echo $! > "$RCLONE_WEB_PID"
    echo "RClone web process started with PID($!)"
fi
