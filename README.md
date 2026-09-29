# shell-config

zsh + Starship 配置。提示符用纯文本符号，不需要 Nerd Font。

Starship 使用官方 [Plain Text Symbols](https://starship.rs/presets/plain-text) 预设，安装时按已装版本从 [starship/starship](https://github.com/starship/starship) 对应 tag 拉取。Debian 会先查 GitHub latest release 再安装该版本。

## 安装

### macOS

需要已安装 [Homebrew](https://brew.sh)。

```bash
curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install-macos.sh | bash
```

或克隆后本地执行：

```bash
git clone https://github.com/AimLuo/ghostty-terminal-config.git
cd ghostty-terminal-config
bash install-macos.sh
```

### Debian 13

前提：已安装 `git` 和 `zsh`。

```bash
curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install-debian.sh | bash
```

脚本会安装 Starship、fzf、zoxide、eza、bat、yazi 和 zsh 插件，把配置写到 `~/.config/shell-config/`，并在 `~/.zshenv` / `~/.zshrc` 追加一段 `shell-config` 引用。已有 `starship.toml` 会备份到 `~/.config-backup/`。

装完后开一个新的 zsh 会话。环境变量在 `~/.zshenv`，只 `source ~/.zshrc` 不会重载它们。

## 装到哪里

| 路径 | 作用 |
|------|------|
| `~/.config/shell-config/zshenv/` | 环境变量、PATH |
| `~/.config/shell-config/zshrc/` | 交互配置（历史、补全、插件、别名、Starship） |
| `~/.config/starship.toml` | 安装时按已装 Starship 版本从 GitHub tag 拉取的预设 |
| `~/.zshenv` / `~/.zshrc` | 追加 `# >>> shell-config >>>` 段，分别 source 上面两个目录 |

## 仓库结构

```
zshenv/               环境变量（安装后落到 ~/.config/shell-config/zshenv）
  env.zsh
zshrc/                交互配置（安装后落到 ~/.config/shell-config/zshrc）
  main.zsh            按顺序 source 其余模块
  history.zsh         zsh 历史（不是 brew 包）
  zsh-completions.zsh
  fzf.zsh
  zoxide.zsh
  yazi.zsh
  eza.zsh
  bat.zsh
  aliases.zsh         常用短别名
  zsh-autosuggestions.zsh
  starship.zsh
  zsh-syntax-highlighting.zsh  须最后加载
install-macos.sh
install-debian.sh
```

## 常用能力

- 提示符：`>` / `x` / `git` / `nodejs` 这类 ASCII 符号
- `z foo` 智能跳转目录
- `y` 打开 yazi，退出后留在当前浏览目录
- `ls` / `ll` / `lt` 走 eza，`cat` 走 bat
- Ctrl+R 搜历史，Ctrl+T 搜文件

## 卸载

删除 `~/.zshenv` 和 `~/.zshrc` 中 `# >>> shell-config >>>` 到 `# <<< shell-config <<<` 之间的内容，然后：

```bash
rm -rf ~/.config/shell-config
```
