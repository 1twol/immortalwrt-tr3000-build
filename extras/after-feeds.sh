#!/bin/bash
#
# feeds 更新后的源码修正（可选）
#
set -e

# 部分分支的 rust 默认拉取 ci-llvm，构建机上不可用
if [ -f feeds/packages/lang/rust/Makefile ]; then
  sed -i 's/ci-llvm=true/ci-llvm=false/g' feeds/packages/lang/rust/Makefile
fi

# 产物文件名加入日期
if [ -f include/image.mk ]; then
  sed -i -e '/^IMG_PREFIX:=/i BUILD_DATE := $(shell date +%Y%m%d)' \
         -e '/^IMG_PREFIX:=/ s/\($(SUBTARGET)\)/\1-$(BUILD_DATE)/' include/image.mk
fi
