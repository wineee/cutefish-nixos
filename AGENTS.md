# AGENTS.md

面向 AI 编码代理（及人类维护者）的工作指南。文档总览与进度见
`docs/survey.md`。

> **前提**：本仓库大量依靠 AI 代理维护，改动**不保证**达到合入 nixpkgs 的
> 标准（`meta` 正确性、许可证、审查深度、能否上游化都不做承诺），不要原样
> 回传上游。另外**实机启动尚未验证**：17 个包与 VM 镜像能构建，但会话需要
> 宿主 GPU 的 DRM/EGL。

## 项目定位

把 Cutefish（`github.com/cutefishos`）移植到 NixOS。上游没有 tag、日更，全部
按 commit 钉；toolkit 用自研 UI 工具包（Skia 在 GLES 上自绘），不走 Qt/DTK。
本仓库从 `dde-cutefish-for-nixos` 拆出，与 DDE 无关。

## 常用命令

```bash
nix build .#<pkg> --no-link                       # 构建单个包
nix build .#<pkg> --print-out-paths --no-link     # 取 store 路径
nix flake show                                    # 暴露的所有包
nix-instantiate --parse <file.nix>                # 改完 .nix 先做语法检查

# 模块求值（vm 是独立 flake，必须在 vm/ 里跑）
cd vm && nix eval --raw .#nixosConfigurations.vm.config.system.build.toplevel.drvPath

# 取上游最新 commit（上游无 tag）
git ls-remote git@github.com:cutefishos/<repo> refs/heads/main
```

## 目录布局

```
flake.nix             # packages.<system>.* / nixosModules.cutefish / legacyPackages.cutefish
packages/default.nix  # 包集唯一维护清单（lib.fix 自举）
packages/<pkg>/       # 每个包一个目录，patch 放在包目录里
nixos-modules/        # cutefish.nix（桌面总入口）+ dm.nix + artwork.nix
vm/                   # 独立 flake：qemu-vm + 真会话
docs/                 # survey / toolkit / core / apps
src/                  # 上游源码 clone 与快照（gitignore，不提交）
```

## 关键约定

### 升级
- **整套一起升**：`cutefish-toolkit` / `cutefish-framework` /
  `cutefish-compositor` / `cutefish-core` 之间是私有 Wayland 协议
  （`cutefish-shell-v1` 等），版本错配会运行期崩。要升就同一天一起升。
- 升级后**必须**跑 `nix build .#<pkg> --no-link`，并同步更新 `docs/`。

### 取 hash（本环境唯一快路）
`nix-prefetch-url` 走代理必 502。用：

```bash
env -u https_proxy -u HTTPS_PROXY curl -sSL -o x.tgz \
  https://codeload.github.com/cutefishos/<repo>/tar.gz/<rev>
# 用 python tarfile 解压（tar 命令会满屏 utime 噪音）
nix hash path --sri --type sha256 <解压后的内层目录>
```

### 路径修复方式（优先级从高到低）
1. **patch 文件**（`patches = [ ./xxx.patch ]`），删代码块、改逻辑用这个。
2. **substituteInPlace 精确替换**，逐文件列出 + `--replace-fail`。
3. **避免** `find -exec sed`、大范围 sed 正则——会误伤打包脚本和测试。

判「这个 patch 该不该提上游」：改动放到 FHS 发行版（`CMAKE_INSTALL_PREFIX=/usr`）
下是否也正确？是本就是上游 bug（提 PR），只在 store 布局下成立就是打包适配。

### 提交规范
中文团队 Conventional Commits 风格，信息从简：

```
<type>(<scope>): <中文简述>
```

type：`feat`/`fix`/`refactor`/`remove`/`chore`；scope 用包名或目录。
只 add 自己改的文件；GPG 签名在本环境必然失败，用 `--no-gpg-sign`。

## 常见坑

- **改动要先 `git add` 再 `nix build`/`nix eval`**：`builtins.getFlake
  "git+file://..."` 只拷贝已跟踪文件，新目录没 add 会报 "No such file"。
  新仓库第一次提交前，`nix build .#<pkg>` 会因为 src 未跟踪而看不到包。
- **`vm/` 是独立 flake**：在主仓库跑 `nix eval .#nixosConfigurations...` 会报
  "does not provide attribute"。
- **meta 维护者**统一写 `maintainers = with lib.maintainers; [ wineee ];`
  （不要用 `lib.teams.deepin`，上游团队已删）。
- **`services.displayManager.sessionPackages` 不进系统 profile**：它只构造
  `sessionData.desktops`，其 `share` 进 `XDG_DATA_DIRS`。所以 `dm.nix` 把
  `Session/Directories` 指向 `sessionData.desktops/share/wayland-sessions`，
  会话自己的命令另外放进 `environment.systemPackages`。
- **`security.pam.services.<n>.startSession` 在设了 `text` 时无效**：`text`
  覆盖默认拼装，`pam_systemd.so` 不会自动加，要手写或 `include login`。
- **模块同一属性不能定义两次**（如两处 `environment.etc`），要 `lib.mkMerge`。
- **注释精简**：包定义里的注释 3-4 行以内，只写「为什么」。长篇论证放
  `docs/`。
- **扫 store 产物只认当前 flake 解析的那个**：`ls -dt /nix/store/*<name>-*`
  会命中历史构建造成假阳性，用 `--print-out-paths`。
- **`/tmp` 不稳**（目录会消失），临时文件写到工作区，解压用 python tarfile。
- **本环境 utime 被拒**：`tar` / `touch` / gpg 签名都会报错，属环境限制。
