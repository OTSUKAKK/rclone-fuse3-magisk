#!/system/bin/sh

MODPATH=${0%/*}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  set_perm_recursive $MODPATH/system/vendor/bin/ 0 0 0755
}

set_permissions

MODULE_ENV="/data/adb/modules/rclone/env.user"
MODULE_HTPASSWD="/data/adb/modules/rclone/htpasswd"
[ -f "$MODULE_ENV" ] && cp "$MODULE_ENV" "$MODPATH/" && ui_print "copy env.user"
[ -f "$MODULE_HTPASSWD" ] && cp "$MODULE_HTPASSWD" "$MODPATH/" && ui_print "copy htpasswd"

MODULE_PROP="${MODPATH}/module.prop"
MODULE_CONFIG="/data/adb/modules/rclone/rclone.config"

if [ -f "$MODULE_CONFIG" ] || [ -f "$MODULE_ENV" ] ; then
  ui_print "✅ 已检测到配置文件 ${MODULE_CONFIG}，已复制到模块目录"
  cp "$MODULE_CONFIG" "$MODPATH/" 
  sed -i 's/^description=\(.\{1,4\}| \)\?/description=✅| /' "$MODULE_PROP"
else
  ui_print "⚙️ 未检测到配置文件，通过命令行或者web进行配置"
  ui_print " Web GUI: 启动 Action 访问对应端口"
  ui_print " 命令行: rclone-config (root) 进入配置"
  sed -i 's/^description=\(.\{1,4\}| \)\?/description=⚙️| /' "$MODULE_PROP"
fi
