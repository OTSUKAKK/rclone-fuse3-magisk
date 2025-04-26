#!/system/bin/sh

MODPATH=${0%/*}
source "$MODPATH/env"

L() {
    echo "[rclone] $1"
    log -t Magisk "[rclone] $1"
}

# 检查 rclone web 是否运行
check_rclone_web() {
    if [ -f "$RCLONE_WEB_PID" ]; then
        PID=$(cat "$RCLONE_WEB_PID")
        if [ -d "/proc/$PID" ]; then
            L "rclone web 正在运行，PID: $PID"
            kill $PID && rm -f "$RCLONE_WEB_PID"
            return 0  # 进程存在
        else
            rm -f "$PIDFILE"  # 清理无效的 PID 文件
        fi
    fi
    return 1  # 进程不存在
}

if check_rclone_web; then
    L "rclone web 已关闭"
else
    L "rclone web 未运行，正在启动..."
    rclone-web --no-auth
fi
