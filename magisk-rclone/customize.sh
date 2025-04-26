#!/system/bin/sh

MODPATH=${0%/*}

echo "===================="
echo "     rclone"
echo "===================="


set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive $MODPATH/system/vendor/bin/ 0 0 0755
}

set_permissions

MODULE_PROP="${MODPATH}/module.prop"
CURRENT_MODULE_CONFIG="${MODPATH}/rclone.config"
MODULE_CONFIG="/data/adb/modules/magisk-rclone/rclone.config"

if [ -f "$CURRENT_MODULE_CONFIG" ] || [ -f "$MODULE_CONFIG" ]; then
    ui_print "✅ 已检测到配置文件"
    sed -i 's/^description=\(.\{1,4\}| \)\?/description=✅| /' "$MODULE_PROP"
else
    ui_print "⚙️ 未检测到配置文件，运行 rclone-config 进行配置"
    sed -i 's/^description=\(.\{1,4\}| \)\?/description=⚙️| /' "$MODULE_PROP"
fi