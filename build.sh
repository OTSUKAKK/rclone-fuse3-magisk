#!/bin/bash


git clone https://github.com/libfuse/libfuse.git --branch fuse-3.17.x --depth 1
git clone https://github.com/Azure/azure-storage-fuse.git --depth 1

mkdir -p output

# build libfuse
cd libfuse

# 配置交叉编译环境
export TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64
export PATH=$TOOLCHAIN/bin:$PATH
export SYSROOT=$TOOLCHAIN/sysroot

# 以 arm64-v8a 为例，其他架构类似
export TARGET_HOST=aarch64-linux-android
export API=21
export CC=$TARGET_HOST$API-clang
export CXX=$TARGET_HOST$API-clang++
export AR=llvm-ar
export LD=ld.lld
export RANLIB=llvm-ranlib
export STRIP=llvm-strip

mkdir build && cd build
cmake .. \
  -DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
  -DCMAKE_ANDROID_NDK=$ANDROID_NDK_HOME \
  -DCMAKE_SYSTEM_VERSION=$API \
  -DCMAKE_ANDROID_STL_TYPE=c++_static \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_INSTALL_PREFIX=$(pwd)/../../libfuse-android-output/arm64-v8a

make -j$(nproc)
make install
cd ../..


# 交叉编译 azure-storage-fuse
cd azure-storage-fuse

export NDK_TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin
export CGO_ENABLED=1

abi = "arm64-v8a"
GOARCH = "arm64"

export CC="$NDK_TOOLCHAIN/${platforms[$abi]}21-clang"
export CXX="$NDK_TOOLCHAIN/${platforms[$abi]}21-clang++"
echo "Building for $abi ($GOARCH)..."
go build -o ../output/blobfuse2-$abi
