#!/bin/bash

git clone https://github.com/Azure/azure-storage-fuse.git azure-storage-fuse --depth 1

mkdir -p output
cd azure-storage-fuse

export NDK_TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin
export CGO_ENABLED=1

declare -A platforms
platforms=(
  ["arm64-v8a"]="aarch64-linux-android"
  ["armeabi-v7a"]="armv7a-linux-androideabi"
  ["x86_64"]="x86_64-linux-android"
)

for abi in "${!platforms[@]}"; do
  case "$abi" in
    "arm64-v8a") export GOARCH=arm64 ;;
    "armeabi-v7a") export GOARCH=arm ;;
    "x86_64") export GOARCH=amd64 ;;
  esac
  export CC="$NDK_TOOLCHAIN/${platforms[$abi]}21-clang"
  export CXX="$NDK_TOOLCHAIN/${platforms[$abi]}21-clang++"
  echo "Building for $abi ($GOARCH)..."
  go build -o ../output/blobfuse2-$abi
done