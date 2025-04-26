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
API=${2:-28} # 如果未传入第二个参数，则默认使用 28 (Andorid 9)

# 检查传入的 $abi 是否有效
if [[ -z "${platforms[$abi]}" ]]; then
  echo "Error: Unsupported ABI '$abi'. Supported ABIs are: ${!platforms[@]}"
  exit 1
fi

# 创建必要目录
mkdir -p output
mkdir -p libfuse-android-output
LIB_FUSE_DIR=$(pwd)/output

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
  -Dutils=true \
  -Dexamples=false \
  -Dtests=false \
  -Ddisable-mtab=true \
  -Dbuildtype=release \
  --default-library=static

# 使用 ninja 编译和安装
ninja -C build

cd ..
echo "==============Finished $abi (API $API) =============="
