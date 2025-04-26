#!/system/bin/sh

MODPATH=${0%/*}

echo "Loading Environment Variables from:"
echo "  * $MODPATH/env"
echo "  * $MODPATH/env.user"

set -a && source "$MODPATH/env" && set +a

# L() {
#     echo "[rclone] $1"
# }

# 检查 rclone web 是否运行
# check_rclone_web() {
#     if [ -f "$RCLONE_WEB_PID" ]; then
#         PID=$(cat "$RCLONE_WEB_PID")
#         if [ -d "/proc/$PID" ]; then
#             L "rclone web 正在运行，PID: $PID"
#             kill $PID && rm -f "$RCLONE_WEB_PID"
#             return 0  # 进程存在
#         else
#             rm -f "$RCLONE_WEB_PID"  # 清理无效的 PID 文件
#         fi
#     fi
#     return 1  # 进程不存在
# }

# if check_rclone_web; then
#     L "web GUI 已关闭"
# else
#     L "Web 未运行，正在启动..."
#     rclone-web --rc-addr=":8000" --rc-no-auth &
#     echo $! > "$RCLONE_WEB_PID"  # 记录 PID
#     L "Web GUI 端口 8000 正在运行，PID: $(cat "$RCLONE_WEB_PID")"
# fi

echo "rclone web GUI started ${RCLONE_RC_ADDR}"

/vendor/bin/rclone-web
