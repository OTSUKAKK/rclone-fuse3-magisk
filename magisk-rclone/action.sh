#!/system/bin/sh

MODPATH=${MODPATH:-/data/adb/modules/rclone}

echo "Loading Environment Variables from:"
echo "  * $MODPATH/env"
set -a && source "$MODPATH/env" && set +a
echo "  * $RCLONE_CONFIG_DIR/env"

# 检查并停止正在运行的 RClone Web 进程
function check_stop_web_pid() {
  if [ -f "$RCLONE_WEB_PID" ]; then
    PID=$(cat "$RCLONE_WEB_PID")
    if ps -p "$PID" > /dev/null 2>&1; then
      echo "RClone Web GUI is already running with PID($PID). Stopping it..."
      kill $PID
      rm -f "$RCLONE_WEB_PID"
      echo "RClone Web GUI stopped successfully."
      echo "已成功关闭 RClone Web GUI"
      return 1
    else
      echo "Found a stale PID file. Removing it..."
      rm -f "$RCLONE_WEB_PID"
    fi
  fi
  return 0
}

function start_web() {
  # 构建 RClone Web GUI 的访问 URL
  if [[ "${RCLONE_RC_ADDR}" == :* ]]; then
    LOCAL_IP=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
    URL="http://${LOCAL_IP:-localhost}${RCLONE_RC_ADDR}"
  else
    URL=${RCLONE_RC_ADDR}
  fi

  set -e
  echo "RClone Web GUI will start at: ${URL}"
  echo "Open the following URL in your browser to access the web GUI:"
  echo "浏览器访问: ${URL} 进行配置"

  # 启动 RClone Web 进程并保存 PID
  if [ -f "$RCLONE_CONFIG_DIR/htpasswd" ]; then
    echo "Found htpasswd file. Using it for authentication."
    nohup /vendor/bin/rclone-web --rc-htpasswd="$RCLONE_CONFIG_DIR/htpasswd" > "$RCLONE_CACHE_DIR/rclone-web.log" 2>&1 &
  else
    echo "No htpasswd file found at $RCLONE_CONFIG_DIR. Starting without authentication."
    nohup /vendor/bin/rclone-web > /dev/stdout 2>&1 &
    nohup /vendor/bin/rclone-web > "$RCLONE_CACHE_DIR/rclone-web.log" 2>&1 &
  fi
  PID=$!
  echo "$PID" > "$RCLONE_WEB_PID"
  echo "RClone Web GUI started with PID($PID)."
  echo "网页已启动 $URL"
}

if check_stop_web_pid; then
  start_web
fi
