# ImmortalWrt 通用云编译模板

基于 GitHub Actions 的 ImmortalWrt / OpenWrt 固件编译模板。源码仓库、分支、commit、设备配置和第三方包都可以按次指定，不绑定具体设备或版本。

## 快速开始

Actions → `ImmortalWrt Builder` → `Run workflow`：

| 输入 | 说明 | 默认值 |
| --- | --- | --- |
| `repo` | 源码仓库地址 | `chasey-dev/immortalwrt-mt798x-rebase` |
| `branch` | 源码分支 | `25.12` |
| `config` | 配置文件路径（相对仓库根） | `config/25.12-256m.config` |
| `device` | 设备标识，仅用于产物/Release 命名 | `TR3000-256M` |
| `commit` | 指定 commit，留空用分支最新 | 空 |
| `extras` | 是否编译第三方包（`extras/` 与 `package/`） | `true` |
| `ssh` | 是否开 SSH 进 `menuconfig` 并回推配置 | `false` |
| `release` | 是否发布到 Release | `true` |
| `prerelease` | 是否预发布 | `false` |

产物包含 `*sysupgrade.bin` 和 `sha256sums.txt`，同时上传 Artifacts 与 Release。

## 目录结构

```
config/                 # 设备配置（.config），按需增加
extras/clones.txt       # 第三方包 git 列表：<url> [目标目录]
extras/after-clone.sh   # 克隆后的修正（可选）
extras/after-feeds.sh   # feeds 更新后的源码修正（可选）
package/                # 本地包，构建时复制进源码树
diy-part1.sh            # 通用前置钩子
diy-part2.sh            # 通用后置钩子
```

## 增加新设备

1. 生成配置：本地 `make menuconfig` 后保存 `.config`，或在本模板勾选 `ssh=true`，在 Action 里执行 `make menuconfig`，保存后 `touch "$GITHUB_WORKSPACE/continue"`（15 分钟内完成），配置会自动提交回 `config/`。
2. 把文件放到 `config/`，触发时填对应 `config` 路径即可。

## 第三方包

- 需要克隆的仓库写进 `extras/clones.txt`，每行 `url [目标目录]`。
- 需要随仓库携带的包放到 `package/`，构建前会整体复制。
- 需要改源码的地方写到 `extras/after-feeds.sh`，它在 `feeds install` 之后执行。
- `extras=false` 时以上全部跳过，只编官方 feeds。

## 预设示例

| 场景 | repo | branch | config |
| --- | --- | --- | --- |
| TR3000 25.12（闭源 MTK WiFi，apk） | `chasey-dev/immortalwrt-mt798x-rebase` | `25.12` | `config/25.12-256m.config` |
| TR3000 24.10（6.6 内核，opkg） | `padavanonly/immortalwrt-mt798x-6.6` | `openwrt-24.10-6.6` | `config/256m.config` |

25.12 起包管理器为 `apk`，安装命令是 `apk add`；24.10 仍为 `opkg install`。自编固件的 `kmod-*` 不要从在线源安装，vermagic 不匹配会失败。

## 刷写

刷写前先备份当前配置：

```sh
ssh root@<router> 'sysupgrade -b /tmp/config.tar.gz'
scp root@<router>:/tmp/config.tar.gz ./backups/
```

上传固件后先在设备上校验，再决定是否刷写：

```sh
scp <image>.bin root@<router>:/tmp/
ssh root@<router> 'sysupgrade -T /tmp/<image>.bin'
```

## U-Boot 编译

`798x-UBOOT` 工作流同样参数化：`repo`、`branch`、`soc`、`boards`。`boards` 格式为 `board:layout`，空格分隔，例如：

```
cudy_tr3000-v1-256mb:0 cudy_tr3000-v1:1
```

## 定时检查

`Update Checker` 每月 1 日检查源码更新，有新提交时触发编译。可在仓库 Settings → Variables 覆盖：

`SOURCE_REPO`、`SOURCE_BRANCH`、`BUILD_CONFIG`、`BUILD_DEVICE`、`BUILD_EXTRAS`。

## License

[MIT](LICENSE) © P3TERX / 上游贡献者
