# CutefishOS 移植调研与现状

调研起点 2026-10-21，最近整理 2026-11-16（PR #4 合并后）。
上游数据取自 GitHub API 与 `cutefishos/packaging` 的 `versions` /
`debian/*/control`。细节按主题分在 [toolkit.md](toolkit.md)、
[core.md](core.md)、[apps.md](apps.md)；本机操作约定见 [`AGENTS.md`](../AGENTS.md)。

## 一、当前状态（2026-11-16）

- **20/20 个包构建通过**：`cutefish-skia`、`cutefish-toolkit`、
  `cutefish-framework`、`cutefish-compositor`、`cutefish-core`、`cutefish-dm`、
  `cutefish-icons`、`cutefish-wallpapers`、`cutefish-qt-plugins`、
  `xdg-desktop-portal-cutefish`、`cutefish-computer-use`，以及应用
  `text-editor` / `filemanager` / `settings` / `terminal` / `video-player` /
  `calendar` / `system-monitor` / `calculator` / `preview`。
- **技术栈已换代**：不再是早期 Cutefish 0.x 的 Qt5 + KF5 路线，而是自研
  toolkit（Wayland 客户端 + Skia 在 GLES 上绘制）、C++20；Qt 只出现在可选的
  `qt-plugins`（Qt6 平台主题）里。系统集成面比 DDE 小：没有 dconfig /
  gsettings 双配置体系，服务是普通 D-Bus 服务，但要接 PAM、polkit agent、
  udev、XDG portal、wayland-sessions。
- **模块与 VM**：`nixosConfigurations.vm` 求值通过，VM 镜像能构建。
  **真机 / VM 里的实际会话启动仍未验证**：沙箱没有宿主 GPU 的 DRM/EGL。
- **模块接线**已覆盖 wayland-sessions、system/user D-Bus、udev、systemd unit、
  XDG portal、Qt 插件路径（`QT_PLUGIN_PATH`）、PipeWire、`cutefish-dm`
  全套（greeter 用户、PAM 栈、`display-manager.service` 别名、
  `/etc/cutefish-dm.conf`、PipeWire user drop-in）。详见
  [core.md](core.md) 第五、六节。
- **有意不打**：`cutefish-installer`（NixOS 有自己的安装器）、
  `cutefish-webkit`（WebKit 分支，体量不值当）。
- 上游不发布 tag（最新仍是 `0.8`，而 `packaging/versions` 写 `1.0`），
  每个包钉 commit。`toolkit` / `framework` / `compositor` / `core`
  之间跑私有 Wayland 协议，必须同日一起升级。

## 二、上游仓库概览

26 个公开仓库（2026-11 复核），其中 20 个需要打成 Nix 包，1 个纯元包
`cutefish-desktop`（由 NixOS 模块代替），其余 5 个是组织配置 / 打包脚本 /
官网 / 空壳仓库。

| 仓库 | 语言 | 归类 | 移植 |
|---|---|---|---|
| cutefish-toolkit | C++ | 自研 UI 工具包（内嵌 Skia） | 必须，最先 |
| cutefish-framework | C++ | 系统能力客户端（声音/网络/蓝牙/电源/PDF/头像） | 必须 |
| cutefish-compositor | C++ | Wayland 合成器 + shell（dock/通知/控制中心） | 必须 |
| cutefish-dm | C++ | 显示管理器（PAM + greeter + session） | 必须 |
| cutefish-core | C++ | 会话、系统服务、polkit agent、录屏 | 必须 |
| filemanager | C++ | 应用 | 是 |
| settings | C++ | 应用 | 是 |
| terminal | C++ | 应用（GPL-3.0） | 是 |
| text-editor | C++ | 应用 | 是 |
| video-player | C++ | 应用 | 是 |
| calendar | C++ | 应用 | 是 |
| system-monitor | C++ | 应用 | 是 |
| calculator | C++ | 2026-11 解除归档并重写为 toolkit 应用 | 是 |
| preview | C++ | 2026-11 新增的图片/PDF 查看器 | 是 |
| xdg-desktop-portal-cutefish | C++ | 门户后端 | 必须（桌面功能完整性） |
| cutefish-computer-use | Rust | AI 控制（MCP server，wayland + 截图编码） | 是（模块 opt-in） |
| qt-plugins | C++ | Qt6 平台主题/图片格式/滚动 | 可选 |
| icons | CMake | 图标主题（GPL-3.0） | 是 |
| wallpapers | CMake | 壁纸 + 账号头像（许可 NOASSERTION，需人工确认） | 是（unfree） |
| cutefish-skia | — | 上游 toolkit 内嵌的 pinned Skia，单独打成 derivation | 必须 |
| cutefish-installer | C++ | 安装器（分区/daemon/polkit） | 否 |
| cutefish-webkit | C++ | 自研 WebKit（WPE 派生，2026-11 新增） | 暂不（体量） |
| cutefish-desktop | — | 纯元包 | 否 |
| packaging | Shell | Debian 打包 + CI | 否（`debian/control` 是依赖权威来源） |
| .github | Shell | 组织配置 + CI | 否 |
| website（cutefishos.github.io） | Astro | 官网 | 否 |
| getting-started / plymouth-theme | — | 只有 README / 2021 年后停更 | 否 |

组织描述已改为 "A beautiful, agentic Linux distribution, formerly CutefishOS"，
方向明显转向 AI agent 桌面：`cutefish-computer-use`、compositor 的
`cutefish-computer-control-v1` 协议、core 里"记住允许的 agent 应用"。

## 三、依赖分层

```
cutefish-toolkit  ──►  pinned Skia(chrome/m156, 源码编译) + wayland-client + EGL/GLES
       ▲                  + fontconfig/freetype/harfbuzz/icu + png/jpeg/webp/tiff/heif/jxl
       │
cutefish-framework ──► pipewire, systemd, icu, png, fontconfig + nixpkgs pdfium
       ▲                  (clients: 音频/网络/蓝牙/电源/PDF/头像)
    ┌──┴───────────────┬─────────────────┐
cutefish-compositor  cutefish-core     cutefish-dm
 (wayland/seat/drm/  (session, services,(pam, systemd,
  gbm/input/udev/     polkit-agent,      dbus policy)
  xcb/xwayland/pw)    ffmpeg/va/vaapi)
       ▲
    应用：filemanager / settings / terminal / text-editor / video-player /
          calendar / system-monitor / calculator / preview /
          xdg-desktop-portal-cutefish
       ▲
    artwork：icons / wallpapers(unfree)；可选：qt-plugins(Qt6)
    独立：cutefish-computer-use(Rust MCP server，不依赖 C++ 协议栈)
```

**强耦合警告**：toolkit 与 compositor 之间跑自研 wayland 协议
（`cutefish-shell-v1`、`cutefish-surface-blur-v1`、`cutefish-window-hints-v1`、
`cutefish-computer-control-v1`），两侧必须同版本构建，不能各自追 HEAD。

## 四、外部依赖 → nixpkgs

| 上游依赖 | nixpkgs | 备注 |
|---|---|---|
| wayland / wayland-protocols >= 1.39 | `wayland` `wayland-protocols` | 已确认当前 lock 里是 1.49 |
| egl / glesv2 / libdrm / libgbm | `libglvnd` `mesa` | |
| libseat / libinput / libudev | `seatd` `libinput` `systemd` | seatd 0.9.3 可用 |
| xkbcommon / xcb* / Xwayland | `libxkbcommon` `xorg.libxcb*` `xwayland` | compositor 内置 xwayland 支持 |
| pipewire >= 0.3 | `pipewire` | 录屏 + greeter 静音 drop-in；1.6.9 可用 |
| ffmpeg + libva | `ffmpeg` `libva` | 仅 core 录屏 |
| fontconfig / freetype2 / harfbuzz / icu | 同名 | framework 的系统字体与 pdfium 补丁要显式 pkg-config |
| PDFium（上游 pin `chromium/8158`） | `pdfium`（8066） | 补丁切到系统库，见下 |
| png/jpeg/webp/tiff/heif/**jxl** | 同名 | jxl 是运行时 `dlopen`，CMake 会 objdump 校验 SONAME |
| libsystemd / PAM / polkit | `systemd` `pam` `polkit` | |
| clang + gn + ninja | `clang` `gn` `ninja` | 仅 Skia 构建需要；clang 21.1.8 / gn 2026-08-14 / ninja 1.13.2 可用 |
| GoogleTest（仅测试） | `gtest` | 所有仓库 `BUILD_TESTING=OFF` |

运行期依赖服务：`accountsservice`、`polkit`、`power-profiles-daemon`、`udisks2`、
`fuse3`、`NetworkManager`、`bluez`、`gnome-keyring`、`upower`、
`pipewire + wireplumber`。

## 五、已落地的关键决策

### 5.1 Skia 独立 derivation

上游 `scripts/fetch-skia.sh` pin 死 `chrome/m156`，构建期现场拉源码编译。
复用 nixpkgs 的 skia 不可行：版本差 8 个 milestone、nixpkgs 是共享库且未开
Ganesh GL、头文件布局不同、缺 svg/skparagraph/skshaper/skunicode 等模块库。
因此单独打 `cutefish-skia`（gn + ninja + clang，静态库 + 源码根布局头文件），
toolkit 用补丁改为从 `CUTEFISH_SKIA` 取前缀。当前 pin
`ea1e651d7a105f5ca327dfd65d28957957279e2e`，详见 [toolkit.md](toolkit.md)。

### 5.2 framework 改用系统 PDFium

上游新增的 `pdf/` 把 pin 死的 PDFium 编成 hidden object 塞进 `cutefish-pdf`。
`framework-system-pdfium.patch` 加 `-DCUTEFISH_PDFIUM_SYSTEM`，改为
`find_path` / `find_library` 链接 nixpkgs 的 pdfium（8066，与上游 pin 差 92 个
chromium 分支）。API 面抽查齐全，`hello.pdf` 取页数 / 取文本 / 渲染均通过；
`FPDF_LIBRARY_CONFIG` 仍用 version 2。源码的 `#include "public/fpdf_*.h"`
在 `${pdfium.dev}/include` 下原样成立。

### 5.3 FHS 路径逐条适配

只 patch 真正会失败的 install 目标与可执行探测，不按模式批量 sed。
`toolkit-xdg-paths.patch` 把数据/配置目录与可执行查找改读
`XDG_DATA_DIRS` / `XDG_CONFIG_DIRS` / `PATH`；`compositor-nix-paths.patch`
把 companion 可执行文件运行期按 PATH 查再 `canonical()`（core 反向依赖
compositor，不能把它的 store 路径编进来）；wallpapers 的 `avatars/` 与壁纸
安装路径改相对 `share/`，模块用 `environment.pathsToLink` 暴露
`/share/cutefish`。详见 [toolkit.md](toolkit.md) 与 [core.md](core.md)。

### 5.4 computer-use 的 lock 与 opt-in

Rust MCP server 上游 `publish = false` 且没提交 `Cargo.lock`：本地用 cargo
1.98 生成一份（44 crate）放进包目录，src derivation 里删掉指向 Debian 离线
registry 的 `.cargo/config.toml` 再让 `buildRustPackage` vendor。协议 XML 编译期
由 `wayland-scanner` 宏生成，运行时不读文件。compositor 启动按 PATH 找它并做
canonical 校验，所以模块里默认关闭、打开才进 `systemPackages`。MCP 握手与
22 个工具的冒烟已通过。详见 [apps.md](apps.md) 第五节。

### 5.5 批量升级

上游日更，全部钉 commit。批量取 HEAD 与 tarball hash 的脚本在
`/home/ut004971@uos/cf-update/`（不进仓库）。`icons` 有两个多万个文件和大量
悬空符号链接，`nix hash path` 会偏，要以 `nix build` 报的 `got:` 为准。
本机取 hash / 取源码的做法见第八节。

## 六、NixOS 模块集成点

`flake.nix` 暴露 `nixosModules.cutefish`（`default` 同义），注入自己的 overlay，
`pkgs.cutefish.*` 在模块外也能直接用。模块文件为 `nixos-modules/cutefish.nix`
（桌面总入口）、`dm.nix`（显示管理器）、`artwork.nix`（图标与壁纸）。

选项：

```nix
services.desktopManager.cutefish.enable = true;                 # 桌面总开关
services.desktopManager.cutefish.displayManager.enable = true;  # 默认开，可用别的 DM
services.desktopManager.cutefish.computerUse.enable = false;    # 隐私敏感，默认不装
services.cutefish.artwork.enable = true;                        # 图标/壁纸
services.cutefish.artwork.wallpapers.enable = true;             # 壁纸是 unfree
```

| 类型 | 出处 | NixOS 侧做法 |
|---|---|---|
| systemd system unit | dm / core 的 unit（原装到 `/usr/lib/systemd/system`） | `systemd.packages` / `systemd.services` |
| systemd user drop-in | dm 给 pipewire 写静音 drop-in；core 给 document-portal 写 stop drop-in | 铺到 `$out/lib/systemd/user/...` 并由模块接管 |
| PAM | `cutefish-dm{,greeter}.pam` | `security.pam.services.<n>`（NixOS 没有 `@include common-*`） |
| D-Bus system policy / 服务 | core 的一批 `*.service.in`、dm / core 的 policy | `services.dbus.packages` |
| polkit | core 自带 polkit-agent | `security.polkit.enable` + agent 进会话 |
| udev rules | `60-cutefish-ddc.rules`、`60-cutefish-privacy.rules` | `services.udev.packages` |
| wayland-sessions | `core/session/cutefish-wayland.desktop` | `services.displayManager.sessionPackages` |
| XDG portal | `xdg-desktop-portal-cutefish` | `xdg.portal.extraPortals`，backend `cutefish;gtk`（我们只实现 4 个接口） |
| MIME 默认程序 | `preview.desktop` 声明 image/* 与 application/pdf | `xdg.mime.defaultApplications`（`mkDefault`，用户可覆盖） |
| Qt 插件 | `cutefish-qt-plugins` 装在 qtbase 之外 | `environment.variables.QT_PLUGIN_PATH` |
| fontconfig | `cutefish-services/appearance/fontconfig.conf` | 随包安装，运行期生成用户配置 |

`systemd.packages` 只**链接** unit，不会自动 enable：locales / privacy 分别由
D-Bus system bus 激活和 udev tag 触发。`cutefish-wallpapers` 是
`unfreeRedistributable`（Unsplash License），默认装，整机需要
`nixpkgs.config.allowUnfree = true`；关掉 artwork 的 wallpapers 开关即可免此要求。

模块求值验证（新文件必须先 `git add`，`git+file://` 只取已跟踪文件）：

```bash
nix eval --impure --expr '
let flake = builtins.getFlake "git+file:///home/ut004971@uos/cutefish-nixos";
in (flake.inputs.nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [ flake.nixosModules.cutefish ({ ... }: {
    boot.loader.grub.enable = false;
    fileSystems."/" = { device = "/dev/sda"; fsType = "ext4"; };
    system.stateVersion = "26.05";
    services.desktopManager.cutefish.enable = true;
  }) ];
}).config.environment.systemPackages'
```

### VM

`vm/` 是独立 flake（`inputs.cutefish-nixos.url = ".."` + `qemu-vm.nix`，
8 核 / 8G / 16G 盘，2223 端口转发 ssh，virtio-vga-gl）：

```bash
cd vm
nix build --no-write-lock-file --impure
./result/bin/run-nixos-vm
```

起的就是真会话：`cutefish-dm` 占 tty1（登录界面 = `cutefish-compositor
--login`，跑在 `cutefish-greeter` 用户下），`cutefish-wayland` 在 tty2，手动输
`test`/`test` 进会话。**要看登录界面就别开自动登录**：设了
`services.displayManager.autoLogin` 后 `Daemon::autologin()` 成功就直接
`login()`，不启动 greeter。vm 里开了 `allowUnfree`（壁纸）。调试可 ssh 2223
看 `journalctl -u cutefish-dm` / `-u display-manager`，会话日志在
`~/.local/state/cutefish*`；会话挂了还能从 tty2+ 的 getty 登进去。

## 七、已知限制与后续

- **实机 / VM 会话未验证**：需要宿主 GPU 的 DRM/EGL，构建沙箱里没有。
- **jxl 运行期 `dlopen`**：CMake 已用 objdump 校验 SONAME，实际能否找到库
  待实机验证（可能要 wrap `LD_LIBRARY_PATH`）。
- **许可证**：`icons` 是 GPL-3.0、`wallpapers` 标注 NOASSERTION，写
  `meta.license` 前要人工确认实际 LICENSE 文本。
- **compositor 引用的 `/usr/bin/reef`**：上游注释称 "compatibility runtime"，
  组织里没有对应仓库，目前按 PATH 查、找不到就不启用。
- **上游仍在变**：日更且方向转向 AI agent，`cutefish-webkit` 等新仓库还没打。
  推进前先冻结一组同日 commit。
- 有意留着的两处 FHS 路径（理由见 [core.md](core.md) 第二节）：framework 的
  VPN 插件扫描目录（接 `${networkmanager}` 会让每个应用闭包多一个
  NetworkManager）、cutefish-locales 的 Debian locale-gen 布局。

## 八、本机操作备忘

- `nix-prefetch-url` 走代理必 502。取 hash 用直连 codeload + python `tarfile`
  解压 + `nix hash path --sri --type sha256 <内层目录>`；Skia 的 tarball
  80M 但只有约 80 KB/s，要 35–40 分钟，别随便重下。
- `nix build` 自己能下 github archive，所以最省事的是先填个 hash 构建，
  从报错的 `got: sha256-...` 里取真值（`icons` 只能用这个办法）。
- 看源码用 ssh 稀疏检出（https 被代理拒，root 下要显式指定密钥）：

  ```bash
  export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=accept-new \
    -o UserKnownHostsFile=$HOME/.ssh/known_hosts -i $HOME/.ssh/id_ed25519"
  git clone --filter=blob:none --depth 1 git@github.com:cutefishos/<repo>
  ```
