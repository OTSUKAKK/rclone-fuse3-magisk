#!/bin/bash

echo "patch libfuse"
for patch in patch-libfuse3/*.patch; do
  echo "Applying patch $patch..."
  patch -d libfuse -p1 < "$patch"
done