#!/bin/bash
#
# 通用定制脚本（feeds 更新之前执行）
#  1. 按 extras/clones.txt 克隆第三方包
#  2. 把 package/ 下的本地包复制进源码树
#  3. 执行 extras/after-clone.sh（可选）
#
set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"
CLONES="$ROOT/extras/clones.txt"

if [ -f "$CLONES" ]; then
  while read -r url dest _; do
    case "$url" in
      ''|\#*) continue ;;
    esac
    if [ -z "$dest" ]; then
      dest="package/$(basename "$url" .git)"
    fi
    echo "==> clone $url -> $dest"
    git clone --depth 1 "$url" "$dest"
  done < "$CLONES"
fi

if [ -d "$ROOT/package" ]; then
  mkdir -p package
  cp -r "$ROOT/package/." package/
fi

if [ -x "$ROOT/extras/after-clone.sh" ]; then
  "$ROOT/extras/after-clone.sh"
fi
