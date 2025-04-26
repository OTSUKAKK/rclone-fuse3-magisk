
#!/bin/bash
set -e

# 获取传入的参数
ABI=$1

RCLONE_VERSION="v1.69.1"


./scripts/build-libfuse3.sh $ABI
cp magisk-rclone magisk-rclone_$ABI -r
cp libfuse/build/util/fusermount3 magisk-rclone_$ABI/vendor/bin/

./scripts/download-rclone.sh $ABI $RCLONE_VERSION magisk-rclone_$ABI/vendor/bin/rclone

chmod +x magisk-rclone_$ABI/vendor/bin/*


ZIP_NAME="magisk-rclone_$ABI.zip"
zip -r -j $ZIP_NAME magisk-rclone_$ABI
echo "打包完成: $ZIP_NAME"
