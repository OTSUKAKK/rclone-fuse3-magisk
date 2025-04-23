#!/bin/bash

echo "patch libfuse 3.16"
# patch libfuse 3.16 with termux-packages/root-packages/libfuse3
# 确保 termux-packages 的补丁文件存在
PATCH_DIR=$(pwd)/termux-packages/root-packages/libfuse3
if [ ! -d "$PATCH_DIR" ]; then
  echo "Error: Patch directory $PATCH_DIR does not exist."
  exit 1
fi
# 应用补丁到 libfuse 3.16
for patch in $PATCH_DIR/*.patch; do
  echo "Applying patch $patch..."
  patch -d libfuse -p1 < "$patch"
done
sed -i "s/cc.find_library('rt')/cc.find_library('rt', required : false)/" libfuse/lib/meson.build

echo "patch azure-storage-fuse"
#  chaneg C.__O_DIRECT to C.O_DIRECT in azure-storage-fuse/component/libfuse/libfuse_handler.go and libfuse_handler_test_wrapper.go
sed -i 's/C.__O_DIRECT/C.O_DIRECT/g' azure-storage-fuse/component/libfuse/libfuse_handler.go
sed -i 's/C.__O_DIRECT/C.O_DIRECT/g' azure-storage-fuse/component/libfuse/libfuse_handler_test_wrapper.go
