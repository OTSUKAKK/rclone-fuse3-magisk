#!/bin/bash

echo "patch libfuse 3.16"
# patch libfuse 3.16 with 
for patch in patch-libfuse3/*.patch; do
  echo "Applying patch $patch..."
  patch -d libfuse -p1 < "$patch"
done

echo "patch azure-storage-fuse"
#  chaneg C.__O_DIRECT to C.O_DIRECT in azure-storage-fuse/component/libfuse/libfuse_handler.go and libfuse_handler_test_wrapper.go
sed -i 's/C.__O_DIRECT/C.O_DIRECT/g' azure-storage-fuse/component/libfuse/libfuse_handler.go
sed -i 's/C.__O_DIRECT/C.O_DIRECT/g' azure-storage-fuse/component/libfuse/libfuse_handler_test_wrapper.go
