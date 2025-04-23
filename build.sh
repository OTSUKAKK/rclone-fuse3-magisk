#!/bin/bash

# 定义支持的架构
declare -A platforms=(
  ["arm64-v8a"]="aarch64-linux-android"
  ["armeabi-v7a"]="armv7a-linux-androideabi"
  ["x86"]="i686-linux-android"
  ["x86_64"]="x86_64-linux-android"
)

export API=31

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

# 创建必要目录
mkdir -p output
mkdir -p libfuse-android-output
LIB_FUSE_DIR=$(pwd)/libfuse-android-output


# 设置通用的工具链路径
export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64
export PATH=$TOOLCHAIN/bin:$PATH
export SYSROOT=$TOOLCHAIN/sysroot

# 构建 libfuse
# libfuse 需要 meson 和 ninja 构建系统
pip install meson ninja

# 为每个目标架构构建 libfuse
for abi in "${!platforms[@]}"; do
  echo "Building libfuse for $abi..."
  
  cd libfuse

  # 设置架构相关变量
  export TARGET_HOST=${platforms[$abi]}
  export CC=$TARGET_HOST$API-clang
  export CXX=$TARGET_HOST$API-clang++
  export AR=$TOOLCHAIN/bin/llvm-ar
  export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
  export STRIP=$TOOLCHAIN/bin/llvm-strip
  
  # 清理旧构建目录
  rm -rf build
  mkdir -p build
  
  # 先生成 android_cross_file.txt
  cat > android_cross_file.txt << EOF
[binaries]
c = '$CC'
cpp = '$CXX'
ar = '$AR'
strip = '$STRIP'
pkg-config = 'pkg-config'

[host_machine]
system = 'android'
cpu_family = '$(if [[ "$abi" == *"arm"* ]]; then echo "arm"; elif [[ "$abi" == *"x86"* ]]; then echo "x86"; fi)'
cpu = '$(if [[ "$abi" == "arm64-v8a" ]]; then echo "aarch64"; elif [[ "$abi" == "armeabi-v7a" ]]; then echo "armv7a"; elif [[ "$abi" == "x86" ]]; then echo "i686"; else echo "x86_64"; fi)'
endian = 'little'
EOF

  # 然后使用 meson 配置构建
  meson setup build\
    --cross-file=android_cross_file.txt \
    --prefix=${LIB_FUSE_DIR}/$abi \
    -Dudevrulesdir=/dev/null \
    -Dutils=false \
    -Dexamples=false \
    -Dtests=false \
    -Ddisable-mtab=true \
    -Dbuildtype=release \
    -Dcanfigger:default_library=static\
    -Dudevrulesdir=${LIB_FUSE_DIR}/$abi/etc/udev/rules.d

  # 使用 ninja 编译和安装
  ninja -C build
  ninja -C build install

cd ..

# 交叉编译 azure-storage-fuse
cd azure-storage-fuse

  export NDK_TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin
  export CGO_ENABLED=1
  
  export GOOS=android
  # 设置 Go 架构
  case "$abi" in
    "arm64-v8a") export GOARCH=arm64 ;;
    "armeabi-v7a") export GOARCH=arm ;;
    "x86") export GOARCH=386 ;;
    "x86_64") export GOARCH=amd64 ;;
  esac
  
  # 设置 libfuse 的路径和链接选项
  export CGO_CFLAGS="-I${LIB_FUSE_DIR}/$abi/include"
  export CGO_LDFLAGS="-L${LIB_FUSE_DIR}/$abi/lib -lfuse3 -static"

  echo "Building azure-storage-fuse for $abi ($GOARCH)..."
  # 添加 osusergo 标签，使用纯 Go 实现替代 cgo 中对这些用户/组函数的调用
  # go build -tags "netgo,osusergo" -ldflags="-extldflags=-static" -o ../output/blobfuse2-$abi
   go build -tags "netgo,osusergo" -o ../output/blobfuse2-$abi

cd ..
echo "==============Finished $abi =============="
done
