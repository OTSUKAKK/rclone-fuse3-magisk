#!/bin/bash
set -e

ABI=$1
RCLONE_VERSION=$2
SAVE_PATH=$3

case "$ABI" in
arm64-v8a)
    ARCH_URL_PART="armv8a"
    ;;
armeabi-v7a)
    ARCH_URL_PART="armv7a"
    ;;
x86)
    ARCH_URL_PART="x86"
    ;;
x86_64)
    ARCH_URL_PART="x64"
    ;;
*)
    echo "! 不支持的架构: $ABI"
    exit 1
    ;;
esac

# 如果你知道固定版本，可以直接写死

FILENAME="rclone-android-21-${ARCH_URL_PART}.gz"
RCLONE_URL="https://beta.rclone.org/${RCLONE_VERSION}/testbuilds/${FILENAME}"

echo "- 下载 rclone: $RCLONE_URL"
TMP_GZ="/tmp/rclone.gz"
curl -L "$RCLONE_URL" -o "$TMP_GZ" || abort "! 下载失败"

gunzip -c "$TMP_GZ" > $SAVE_PATH
rm -f "$TMP_GZ"

echo "下载完成 🎉"
