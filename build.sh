#!/bin/bash
set -e

# 获取传入的参数
ABI=$1

# 从 magisk-rclone/module.prop 文件中读取 RCLONE_VERSION
RCLONE_VERSION=$(grep -oP '^version=\Kv.*' magisk-rclone/module.prop)

cp magisk-rclone magisk-rclone_$ABI -r

./scripts/download-rclone.sh $ABI $RCLONE_VERSION magisk-rclone_$ABI/vendor/bin/rclone

./scripts/build-libfuse3.sh $ABI
cp libfuse/build/util/fusermount3 magisk-rclone_$ABI/vendor/bin/

chmod +x magisk-rclone_$ABI/vendor/bin/*

ZIP_NAME="magisk-rclone_$ABI.zip"

cd magisk-rclone_$ABI
zip -r9 ../$ZIP_NAME .
cd ..

echo "打包完成: $ZIP_NAME"
