# blobfuse2-android

本项目是 [Azure blobfuse2](https://github.com/Azure/azure-storage-fuse) 的 Android 平台构建版本。

Azure blobfuse2 是由微软 Azure 团队开发的，基于 Go 语言实现的 Azure Blob 存储文件系统挂载工具。

## 项目特性

- 基于 Azure 官方 [blobfuse2](https://github.com/Azure/azure-storage-fuse) 项目构建
- 支持 Android 平台
- 提供跨平台的 Azure Blob 存储挂载能力

## 构建方法

本项目使用 GitHub Actions 自动构建，具体步骤如下：

1. 同步最新的 Azure blobfuse2 源码
2. 使用 Android NDK (版本 27) 进行交叉编译
3. 输出 Android 平台的二进制文件

具体构建流程请参考：[GitHub Actions 配置文件](.github/workflows/build-android.yml)

## 获取二进制文件

构建完成后，可在 GitHub Actions 的 Artifacts 中下载 Android 平台的二进制文件。

## 相关链接

- [Azure blobfuse2 官方仓库](https://github.com/Azure/azure-storage-fuse)
- [Azure Blob 存储官方文档](https://docs.microsoft.com/azure/storage/blobs/)
