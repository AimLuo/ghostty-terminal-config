# Debian 安装方式（一手来源）

调研日期：2026-09-06  
范围：各工具官方文档 / GitHub Releases。面向 Debian 13 (Trixie)。

本仓库 **macOS 与 Debian 是两套配置**：`zsh/.zshrc` + `install.sh` 给 Homebrew；`zsh/debian.zshrc` + `install-debian.sh` 给 Debian。不在一份 zshrc 里探测两边路径。

## 谁有官方 `.deb`

从 GitHub Releases 下载后 `sudo apt install -y ./xxx.deb`。

| 工具 | 官方 .deb | 来源 |
|------|-----------|------|
| bat | 有。`bat_*_amd64.deb` / `_arm64.deb`（不要下 `bat-musl_*`） | [README](https://github.com/sharkdp/bat/blob/master/README.md) On Ubuntu using most recent .deb；[Releases](https://github.com/sharkdp/bat/releases) |
| zoxide | 有。`zoxide_*-1_amd64.deb` 等 | [Releases](https://github.com/ajeetdsouza/zoxide/releases)；维护者在 [#481](https://github.com/ajeetdsouza/zoxide/issues/481) 也提到 DEB |
| fzf | 有，从 [v0.74.1](https://github.com/junegunn/fzf/releases/tag/v0.74.1) 起（changelog：Each release now includes .deb packages） | [Releases](https://github.com/junegunn/fzf/releases) |
| Yazi | 有。`yazi-x86_64-unknown-linux-gnu.deb` / `aarch64-...-gnu.deb` | [Releases v26.9.1](https://github.com/sxyazi/yazi/releases/tag/v26.9.1) |

Trixie 主仓的 `bat` 可执行文件叫 `batcat`；上游 `.deb` 叫 `bat`，所以 Debian 脚本下上游包，debian.zshrc 里 `alias cat=bat`。

## 谁没有官方 `.deb`

| 工具 | 做法 | 来源 |
|------|------|------|
| Starship | 无 `.deb`，Linux 官方 `curl -sS https://starship.rs/install.sh \| sh`；脚本支持 `-y -v v1.26.0 -b ~/.local/bin`。Trixie `apt install starship` 是 **1.22.1**，不能配本仓库钉住的 1.26 预设。 | [starship.rs/guide](https://starship.rs/guide/)；[v1.26.0 assets](https://github.com/starship/starship/releases/tag/v1.26.0) 只有 tar.gz；[Trixie starship](https://packages.debian.org/trixie/utils/starship) |
| eza | GitHub Releases 只有 tar.gz/zip。Trixie 主仓有 `eza`。不加 [deb.gierens.de](https://github.com/eza-community/eza/blob/main/INSTALL.md)。 | [eza Releases](https://github.com/eza-community/eza/releases)；[packages.debian.org/trixie/eza](https://packages.debian.org/trixie/eza) |
| zsh-syntax-highlighting | 上游不发 .deb。官方 INSTALL：Debian 包 + `source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh` | [INSTALL.md](https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md) |
| zsh-autosuggestions | 上游 INSTALL 给 Debian 的是 OBS；Trixie 主仓有包。 | [INSTALL.md](https://github.com/zsh-users/zsh-autosuggestions/blob/master/INSTALL.md)；[packages.debian.org/trixie/zsh-autosuggestions](https://packages.debian.org/trixie/zsh-autosuggestions) |
| zsh-completions | 无 .deb。官方 Manual：`git clone` + `fpath=(.../src $fpath)` | [README](https://github.com/zsh-users/zsh-completions/blob/master/README.md) |

Yazi 前置：官方文档要求 `file`。[installation](https://yazi-rs.github.io/docs/installation)

Starship 官方 install.sh 必须用 `sh` 跑，不能用 zsh/bash。
