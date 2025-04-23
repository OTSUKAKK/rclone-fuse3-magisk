#!/bin/bash

# 定义支持的架构
declare -A platforms=(
  ["arm64-v8a"]="aarch64-linux-android"
  ["armeabi-v7a"]="armv7a-linux-androideabi"
  ["x86"]="i686-linux-android"
  ["x86_64"]="x86_64-linux-android"
)

# 获取传入的参数
abi=$1
API=${2:-31} # 如果未传入第二个参数，则默认使用 31

# 检查传入的 $abi 是否有效
if [[ -z "${platforms[$abi]}" ]]; then
  echo "Error: Unsupported ABI '$abi'. Supported ABIs are: ${!platforms[@]}"
  exit 1
fi

# 创建必要目录
mkdir -p output
mkdir -p libfuse-android-output
LIB_FUSE_DIR=$(pwd)/libfuse-android-output

# 设置通用的工具链路径
export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64
export PATH=$TOOLCHAIN/bin:$PATH
export SYSROOT=$TOOLCHAIN/sysroot

# 构建 libfuse
echo "==============Start $abi (API $API) =============="
echo "Building libfuse for $abi with API level $API..."


# 设置架构相关变量
export TARGET_HOST=${platforms[$abi]}
export CC=$TARGET_HOST$API-clang
export CXX=$TARGET_HOST$API-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip

cd libfuse

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

[properties]
skip_sanity_check = true
sys_root = '$SYSROOT'

[host_machine]
system = 'linux'
cpu_family = '$(if [[ "$abi" == *"arm"* ]]; then echo "arm"; elif [[ "$abi" == *"x86"* ]]; then echo "x86"; fi)'
cpu = '$(if [[ "$abi" == "arm64-v8a" ]]; then echo "aarch64"; elif [[ "$abi" == "armeabi-v7a" ]]; then echo "armv7a"; elif [[ "$abi" == "x86" ]]; then echo "i686"; else echo "x86_64"; fi)'
endian = 'little'

[target_machine]
system = 'android'
cpu_family = '$(if [[ "$abi" == *"arm"* ]]; then echo "arm"; elif [[ "$abi" == *"x86"* ]]; then echo "x86"; fi)'
cpu = '$(if [[ "$abi" == "arm64-v8a" ]]; then echo "aarch64"; elif [[ "$abi" == "armeabi-v7a" ]]; then echo "armv7a"; elif [[ "$abi" == "x86" ]]; then echo "i686"; else echo "x86_64"; fi)'
endian = 'little'
EOF

# 然后使用 meson 配置构建
meson setup build\
  --cross-file=android_cross_file.txt \
  --prefix=${LIB_FUSE_DIR}/$abi \
  -Dutils=false \
  -Dexamples=false \
  -Dtests=false \
  -Ddisable-mtab=true \
  -Dbuildtype=release \
  -Ddefault_library=static \
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
export CGO_LDFLAGS="-L${LIB_FUSE_DIR}/$abi/lib -lfuse3 -static -Wl,-Bdynamic -llog"

echo "Building azure-storage-fuse for $abi ($GOARCH) with API level $API..."
# 添加 osusergo 标签，使用纯 Go 实现替代 cgo 中对这些用户/组函数的调用
 go build -tags "netgo,osusergo" -ldflags="-extldflags=-static" -o ../output/blobfuse2-$abi

cd ..
echo "==============Finished $abi (API $API) =============="
