# 方向

本仓库从「Ghostty 终端美化」改成「终端无关的 zsh + Starship」。

## 做

- 维护 `starship/starship.toml`；zsh 分两套：`zsh/.zshrc`（macOS/Homebrew）与 `zsh/debian.zshrc`（Debian）
- Starship 用官方 [plain-text-symbols](https://starship.rs/presets/plain-text) 预设，内容钉在 **1.26.0**（用该版本 `starship preset` 生成，不跟 GitHub main / 官网未发版文档）
- macOS 用 `install.sh`（Homebrew）；Debian 13 用 `install-debian.sh`（官方 .deb + 主仓，不加第三方源）
- 安装脚本只装 shell 工具，不装 Ghostty，不装字体
- 不改用户已有的终端模拟器配置（包括 `~/.config/ghostty`）
- 重装时把旧 `ghostty-terminal-config` zsh 段替换为 `shell-config`

## 不做

- 不为某个终端写主题、字体、窗口、光标配置
- 不提供深色/浅色安装选项（那是终端模拟器的事）
- 不在 `eza` 上开 `--icons`

## 字体

不必装。依据见 `research/starship-plain-text-and-fonts.md`。
