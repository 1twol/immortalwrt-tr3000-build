# Cudy TR3000 256MB ImmortalWrt 固件编译

本仓库只用于 **Cudy TR3000 v1 256MB**（设备标识 `cudy_tr3000-256mb-v1`）的固件编译，不适用于 128MB 版本。

## 编译入口

Actions 中按版本选择工作流：

| 工作流 | 源码 | 配置 |
| --- | --- | --- |
| `Build 25.12` | `chasey-dev/immortalwrt-mt798x-rebase@25.12` | `config/25.12-256m.config` |
| `Build 24.10` | `padavanonly/immortalwrt-mt798x-6.6@openwrt-24.10-6.6` | `config/256m.config` |
| `Build Auto` | 由 `Update Checker` 定时触发，默认同 25.12 | `config/25.12-256m.config` |

进入 `Build 25.12` 或 `Build 24.10` → `Run workflow`，仓库/分支/配置已预填，可按需修改。

| 输入 | 说明 | 默认 |
| --- | --- | --- |
| `commit` | 指定 commit，留空用分支最新 | 空 |
| `extras` | 是否编译第三方包（`extras/` 与 `package/`） | `true` |
| `ssh` | 是否开 SSH 进 `menuconfig` 并回推配置 | `false` |
| `release` | 是否发布到 Release | `true` |
| `prerelease` | 是否预发布 | `false` |

产物包含 `*sysupgrade.bin` 和 `sha256sums.txt`，同时上传 Artifacts 与 Release。

## 版本差异

- **25.12**：内核 6.12，包管理器 `apk`，带 MTK 闭源 WiFi 驱动
- **24.10**：内核 6.6，包管理器 `opkg`

25.12 刷完后安装软件用 `apk add`，24.10 用 `opkg install`。自编固件的 `kmod-*` 不要从在线源安装，内核版本不匹配会失败。

## 配置与第三方包

- `config/25.12-256m.config`、`config/256m.config`：对应版本的软件包选择
- `extras/clones.txt`：第三方包仓库列表，每行 `<url> [目标目录]`
- `extras/after-clone.sh` / `extras/after-feeds.sh`：克隆后、feeds 更新后的源码修正
- `package/`：随仓库携带的本地包，构建时复制进源码树
- `extras=false` 时跳过以上第三方内容，只编官方 feeds

当前第三方包：aurora 主题、bandix、taskplan、pushbot、mentohust、uugamebooster。

## 刷写

刷写前备份当前配置：

```sh
ssh root@<router> 'sysupgrade -b /tmp/config.tar.gz'
scp root@<router>:/tmp/config.tar.gz ./backups/
```

上传固件后先在设备上校验：

```sh
scp <image>.bin root@<router>:/tmp/
ssh root@<router> 'sysupgrade -T /tmp/<image>.bin'
```

确认无误后再执行 `sysupgrade`，默认保留配置。

## U-Boot

`798x-UBOOT` 工作流编译 Cudy TR3000 的 DHCP U-Boot：

- 128M U-Boot：三分区布局，支持原厂 64MB、扩容 112MB、最大 122MB
- 256M U-Boot：单分区布局

## 定时更新

`Update Checker` 每月 1 日检查源码更新并触发 `Build Auto`。可在仓库 Settings → Variables 覆盖 `SOURCE_REPO`、`SOURCE_BRANCH`、`BUILD_CONFIG`、`BUILD_DEVICE`、`BUILD_EXTRAS`。

## License

[MIT](LICENSE) © P3TERX / 上游贡献者
