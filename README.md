# shell-config

zsh + Starship 配置。不绑定 Ghostty 或任何终端模拟器。macOS 与 Debian 是**两套**安装脚本和 zsh 配置，不要混用。

Starship 使用官方 [Plain Text Symbols](https://starship.rs/presets/plain-text) 预设，内容钉在 **Starship 1.26.0**（由该版本的 `starship preset plain-text-symbols` 生成）。提示符是纯文本符号，不需要 Nerd Font。不要从 GitHub `main` 或 starship.rs 当前文档页拷 TOML，那些会带上尚未发版的模块（例如 `jj_bookmark`）。

## 效果

- 纯文本提示符（`>` / `x` / `git` / `nodejs` 这类 ASCII 符号）
- 语法高亮、自动建议、模糊搜索
- 任意终端可用：Ghostty、iTerm2、Terminal.app、Kitty 等

## 包含的配置文件

| 文件 | 说明 | 安装位置 |
|------|------|---------|
| `starship/starship.toml` | Starship 1.26.0 的官方 plain-text-symbols 预设 | `~/.config/starship.toml` |
| `zsh/.zshrc` | macOS / Homebrew 的 zsh 配置 | `~/.zshrc` |
| `zsh/debian.zshrc` | Debian 的 zsh 配置 | `~/.zshrc` |

## 一键安装

### macOS

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install.sh)
```

1. 通过 Homebrew 安装 Starship 与 zsh 工具（不装终端模拟器，不装字体）
2. 备份已有 Starship 配置
3. 覆盖写入 `~/.config/starship.toml`（明确提示：这是 Starship **1.26.0** 预设）
4. 将 `zsh/.zshrc` 写入 `~/.zshrc`

### Debian 13 (Trixie)

前提：已安装 `git` 和 `zsh`。

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install-debian.sh)
```

1. apt 安装 eza 与 zsh 插件（主仓没有上游 `.deb` 的那些）
2. 从 GitHub Releases 下载官方 `.deb`：bat、zoxide、fzf、yazi
3. Starship 没有官方 `.deb`，用官方 `install.sh` 钉在 1.26.0
4. 写入同一份 1.26 预设，以及 `zsh/debian.zshrc`

不加第三方 apt 源。Starship / eza / zsh 插件为何不走 `.deb`，见 `research/debian-install.md`。

两套脚本都不会改动 `~/.config/ghostty` 或其他终端配置。

## 备份与恢复

安装脚本会把已有 `~/.config/starship.toml` 备份到 `~/.config-backup/<时间戳>/`。

```bash
ls ~/.config-backup/
cp ~/.config-backup/<时间戳>/starship.toml ~/.config/starship.toml
```

### 卸载 zsh 配置

删除 `~/.zshrc` 中 `# >>> shell-config >>>` 到 `# <<< shell-config <<<` 之间的所有内容即可。

## 依赖

| 工具 | 用途 |
|------|------|
| [Starship](https://starship.rs) | 跨 shell 提示符 |
| [fzf](https://github.com/junegunn/fzf) | 模糊搜索（Ctrl+R 搜历史，Ctrl+T 搜文件） |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 智能目录跳转（`z foo` 代替 `cd`） |
| [eza](https://eza-community.github.io/eza/) | 替代 ls |
| [bat](https://github.com/sharkdp/bat) | 替代 cat，语法高亮 |
| [yazi](https://github.com/sxyazi/yazi) | 终端文件管理器 |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | 历史命令自动建议 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | 命令语法高亮 |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Tab 补全增强 |

不安装终端模拟器，也不安装字体。本仓库控制的提示符和 `ls` 别名都不依赖 Nerd Font。

## 手动安装（macOS）

### 1. 安装依赖

```bash
brew install starship fzf zoxide eza bat yazi zsh-autosuggestions zsh-syntax-highlighting zsh-completions
```

### 2. 下载配置文件

```bash
git clone --depth 1 https://github.com/AimLuo/ghostty-terminal-config.git /tmp/shell-config
```

### 3. 安装配置文件

```bash
mkdir -p ~/.config
cp /tmp/shell-config/starship/starship.toml ~/.config/starship.toml
cat /tmp/shell-config/zsh/.zshrc >> ~/.zshrc
```

不要用 GitHub `main` 上的 TOML。若本机 Starship 已是 1.26.x，也可以用该版本自己生成：

```bash
starship preset plain-text-symbols -o ~/.config/starship.toml
```

> 注意：zsh 配置是追加到 `~/.zshrc` 尾部，不会覆盖已有内容。如果重复执行需手动去重。一键脚本会处理去重和旧标记替换。

### 4. 清理并重载

```bash
rm -rf /tmp/shell-config
source ~/.zshrc
```

## 字体还有必要装吗

没有。官方 Plain Text Symbols 预设的用途就是：没有 Unicode / Nerd Font 时也能读提示符。本仓库的 `eza` 别名也不开 `--icons`。

终端本身用什么字体，由你正在用的模拟器决定，不在本仓库安装范围内。

## 快捷键速查

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+F` | 接受自动建议 |
| `Ctrl+R` | fzf 模糊搜索历史命令 |
| `Ctrl+T` | fzf 模糊搜索文件 |
| `Tab` | 补全，连续按在候选列表中移动 |

## 别名速查

| 别名 | 实际命令 |
|------|---------|
| `ls` | `eza --group-directories-first` |
| `ll` | `eza -l --sort=name` |
| `lt` | `eza --tree --level=2` |
| `cat` | `bat --paging=never --style=plain` |
| `y` | yazi 文件管理器（退出自动 cd） |
| `z foo` | zoxide 智能跳转到包含 foo 的目录 |
