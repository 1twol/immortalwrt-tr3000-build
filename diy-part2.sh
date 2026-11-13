#!/bin/bash
#
# 通用定制脚本（feeds 更新之后执行）
# 设备或源码相关的改动放到 extras/after-feeds.sh（可选）。
#
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"

if [ -x "$ROOT/extras/after-feeds.sh" ]; then
  "$ROOT/extras/after-feeds.sh"
fi
