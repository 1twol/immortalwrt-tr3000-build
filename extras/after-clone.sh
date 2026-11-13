#!/bin/bash
#
# 克隆完成后的修正脚本（可选）
#
set -e

# uugamebooster：Makefile 在子目录，且 postinst 使用了绝对路径
if [ -d package/uugamebooster-src/luci-app-uugamebooster ]; then
  mv package/uugamebooster-src/luci-app-uugamebooster package/luci-app-uugamebooster
  rm -rf package/uugamebooster-src
  sed -i -e 's#chmod +x /etc/init.d/uuplugin#chmod +x $${IPKG_INSTROOT}/etc/init.d/uuplugin#' \
         -e 's#chmod +x /usr/libexec/uuplugin/#chmod +x $${IPKG_INSTROOT}/usr/libexec/uuplugin/#g' \
         package/luci-app-uugamebooster/Makefile
fi
