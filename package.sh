
#!/bin/bash
set -e

# 获取传入的参数
ABI=$1

RCLONE_VERSION="v1.69.1"


./build-libfuse3.sh $ABI
cp magisk-rclone magisk-rclone_$ABI -r
cp libfuse/build/util/fusermount3 magisk-rclone_$ABI/vendor/bin/

./download-rclone.sh $ABI $RCLONE_VERSION magisk-rclone_$ABI/vendor/bin/rclone

set_permissions() {
  chmod +x magisk-rclone_$ABI/vendor/bin/*
}

set_permissions