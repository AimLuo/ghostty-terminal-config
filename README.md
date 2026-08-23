# Ghostty Terminal Config

macOS 下基于 Ghostty + Starship + zsh 插件的终端美化方案，从 iTerm2 + oh-my-zsh 迁移而来，更轻量更快。Apple Silicon（M 系列，Homebrew 在 `/opt/homebrew`）与 Intel（`/usr/local`）共用同一套配置，启动时按本机 brew 位置解析。

## 效果

- 彩虹条提示符（基于 Starship 官方 catppuccin-powerline 预设，启用换行显示）
- 半透明毛玻璃窗口
- 语法高亮、自动建议、模糊搜索
- 同系列深色 / 浅色：Catppuccin Mocha 或 Latte，安装时选择

## 包含的配置文件

| 文件 | 说明 | 安装位置 |
|------|------|---------|
| `ghostty/config` | Ghostty 终端配置（字体、主题、窗口、光标） | `~/.config/ghostty/config` |
| `starship/starship.toml` | Starship 彩虹条提示符配置（官方预设 + 换行） | `~/.config/starship.toml` |
| `zsh/.zshrc` | zsh 配置（插件、工具、别名、快捷键） | `~/.zshrc` |
| （安装时生成） | 浅色附加项：bat 主题、自动建议对比度 | `~/.config/ghostty/theme.zsh` |

## 一键安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install.sh)
```

安装前会询问确认，并选择深色或浅色：
1. 通过 Homebrew 安装所有依赖
2. 备份已有 Ghostty 和 Starship 配置文件
3. 按所选主题安装 Ghostty 配置（覆盖）；Starship 彩虹条始终用 Mocha
4. 将 zsh 配置追加到 `~/.zshrc` 尾部（不覆盖用户已有内容）

非交互安装可指定主题：

```bash
THEME=light bash <(curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install.sh)
THEME=dark  bash <(curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install.sh)
```

## 备份与恢复

安装脚本会自动将已有配置备份到 `~/.config-backup/<时间戳>/` 目录。

备份文件对应关系：

| 备份文件 | 原始位置 |
|---------|---------|
| `~/.config-backup/<时间戳>/ghostty-config` | `~/.config/ghostty/config` |
| `~/.config-backup/<时间戳>/ghostty-theme.zsh` | `~/.config/ghostty/theme.zsh` |
| `~/.config-backup/<时间戳>/starship.toml` | `~/.config/starship.toml` |

恢复命令：

```bash
# 查看备份目录（找到对应时间戳）
ls ~/.config-backup/

# 恢复（替换 <时间戳> 为实际目录名）
cp ~/.config-backup/<时间戳>/ghostty-config ~/.config/ghostty/config
cp ~/.config-backup/<时间戳>/starship.toml ~/.config/starship.toml
cp ~/.config-backup/<时间戳>/ghostty-theme.zsh ~/.config/ghostty/theme.zsh
```

### 卸载 zsh 配置

删除 `~/.zshrc` 中 `# >>> ghostty-terminal-config >>>` 到 `# <<< ghostty-terminal-config <<<` 之间的所有内容即可。

## 依赖

| 工具 | 用途 |
|------|------|
| [Ghostty](https://ghostty.org) | GPU 加速终端模拟器 |
| [Starship](https://starship.rs) | 跨 shell 提示符 |
| [fzf](https://github.com/junegunn/fzf) | 模糊搜索（Ctrl+R 搜历史，Ctrl+T 搜文件） |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | 智能目录跳转（`z foo` 代替 `cd`） |
| [eza](https://github.com/eza-community/eza) | 替代 ls，彩色图标 |
| [bat](https://github.com/sharkdp/bat) | 替代 cat，语法高亮 |
| [yazi](https://github.com/sxyazi/yazi) | 终端文件管理器 |
| [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions) | 历史命令自动建议 |
| [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting) | 命令语法高亮 |
| [zsh-completions](https://github.com/zsh-users/zsh-completions) | Tab 补全增强 |
| [Maple Mono NF](https://github.com/subframe7536/maple-font) | 终端字体（Nerd Font，中文显示优秀） |

## 手动安装

### 1. 安装依赖

```bash
brew install --cask font-maple-mono-nf
brew install --cask ghostty
brew install starship fzf zoxide eza bat yazi zsh-autosuggestions zsh-syntax-highlighting zsh-completions
```

### 2. 下载配置文件

```bash
git clone --depth 1 https://github.com/AimLuo/ghostty-terminal-config.git /tmp/ghostty-config
```

### 3. 安装配置文件

```bash
mkdir -p ~/.config/ghostty
cp /tmp/ghostty-config/ghostty/config ~/.config/ghostty/config
cp /tmp/ghostty-config/starship/starship.toml ~/.config/starship.toml
cat /tmp/ghostty-config/zsh/.zshrc >> ~/.zshrc
```

默认是深色（Mocha）。若要用浅色（Latte），只改 Ghostty，彩虹条不用动：

```bash
sed -i '' 's/theme = "Catppuccin Mocha"/theme = "Catppuccin Latte"/' ~/.config/ghostty/config
cat > ~/.config/ghostty/theme.zsh <<'EOF'
export BAT_THEME="GitHub"
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#9ca0b0"
EOF
```

> 注意：zsh 配置是追加到 `~/.zshrc` 尾部，不会覆盖已有内容。如果重复执行需手动去重。

### 4. 清理并重启

```bash
rm -rf /tmp/ghostty-config
```

重启 Ghostty 终端生效。

## 主题

深浅两套只换终端底色（Ghostty），彩虹条始终用 Mocha 粉彩 + 深色字，浅底上也清楚。

| 选项 | Ghostty | Starship palette | 额外调整 |
|------|---------|------------------|----------|
| 深色（默认） | Catppuccin Mocha | `catppuccin_mocha` | 无 |
| 浅色 | Catppuccin Latte | `catppuccin_mocha`（不变） | `bat` 用 GitHub 浅色高亮；自动建议用 Latte overlay 灰，避免看不清 |

安装后改主题：重新运行安装脚本并重新选择，或按上面「手动安装」改 Ghostty 后重启。

## Starship 预设说明

彩虹条基于 `starship preset catppuccin-powerline` 官方预设，唯一改动：

- `[line_break] disabled = false`：彩虹条一行，输入符号在下一行

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
| `ls` | `eza --icons --group-directories-first` |
| `ll` | `eza -l --icons --sort=name` |
| `lt` | `eza --tree --icons --level=2` |
| `cat` | `bat --paging=never --style=plain` |
| `y` | yazi 文件管理器（退出自动 cd） |
| `z foo` | zoxide 智能跳转到包含 foo 的目录 |
