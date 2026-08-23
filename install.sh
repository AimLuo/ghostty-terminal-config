#!/bin/bash

# ==============================================================================
# ghostty-terminal-config 一键安装脚本
# ==============================================================================
# 用法:
#   bash <(curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install.sh)
#
# 说明:
#   1. 选择深色（Catppuccin Mocha）或浅色（Catppuccin Latte）
#   2. 安装 Homebrew 依赖（字体、终端工具、zsh 插件）
#   3. 备份已有配置到 ~/.config-backup/YYYYMMDD_HHMMSS/
#   4. 从 GitHub 下载配置文件到目标位置
#
# 非交互指定主题:
#   THEME=light bash install.sh
#   THEME=dark  bash install.sh
#
# 恢复备份:
#   cp ~/.config-backup/<时间戳>/ghostty-config ~/.config/ghostty/config
#   cp ~/.config-backup/<时间戳>/starship.toml ~/.config/starship.toml
#   cp ~/.config-backup/<时间戳>/ghostty-theme.zsh ~/.config/ghostty/theme.zsh
#
# 卸载 zsh 配置:
#   删除 ~/.zshrc 中 ">>> ghostty-terminal-config >>>" 到 "<<< ghostty-terminal-config <<<" 之间的内容
# ==============================================================================

set -e

REPO_URL="https://github.com/AimLuo/ghostty-terminal-config.git"
BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"
TMP_DIR="$(mktemp -d)"

# 清理临时目录
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# ==============================================================================
# 用户确认
# ==============================================================================
echo ""
echo "======================================"
echo " Ghostty Terminal Config 安装脚本"
echo "======================================"
echo ""
echo "本脚本将执行以下操作:"
echo "  1. 通过 Homebrew 安装终端工具和字体"
echo "  2. 备份已有 Ghostty 和 Starship 配置到 ~/.config-backup/"
echo "  3. 安装新的终端配置（Ghostty + Starship + zsh）"
echo ""
echo "已有配置将备份到: $BACKUP_DIR"
echo ""
read -p "是否继续？(y/n) " -n 1 -r < /dev/tty
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "已取消安装。"
  exit 0
fi
echo ""

# ==============================================================================
# 选择主题
# ==============================================================================
THEME_VARIANT="${THEME:-}"
if [[ -n "$THEME_VARIANT" ]]; then
  case "$THEME_VARIANT" in
    light|latte|Latte) THEME_VARIANT="light" ;;
    dark|mocha|Mocha) THEME_VARIANT="dark" ;;
    *)
      echo "错误: THEME 应为 dark 或 light"
      exit 1
      ;;
  esac
  echo "使用主题: $THEME_VARIANT（来自 THEME 环境变量）"
else
  echo "请选择终端主题:"
  echo "  1) 深色  Catppuccin Mocha（默认，与当前风格一致）"
  echo "  2) 浅色  Catppuccin Latte（终端浅底；彩虹条仍用 Mocha 粉彩 + 深色字）"
  echo ""
  read -p "请输入 [1/2] (默认 1): " -n 1 -r < /dev/tty
  echo ""
  echo ""
  if [[ $REPLY == "2" ]]; then
    THEME_VARIANT="light"
  else
    THEME_VARIANT="dark"
  fi
fi

if [[ "$THEME_VARIANT" == "light" ]]; then
  THEME_LABEL="浅色 · Catppuccin Latte"
else
  THEME_LABEL="深色 · Catppuccin Mocha"
fi
echo "已选择: $THEME_LABEL"
echo ""

# ==============================================================================
# 检查环境
# ==============================================================================
# M 系列 /opt/homebrew 默认不在 PATH 里；Intel 一般是 /usr/local
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if ! command -v brew &> /dev/null; then
  echo "错误: 未检测到 Homebrew，请先安装: https://brew.sh"
  exit 1
fi
echo "    Homebrew: $(brew --prefix) ($(uname -m))"

if ! command -v git &> /dev/null; then
  echo "错误: 未检测到 git，请先安装 Xcode Command Line Tools: xcode-select --install"
  exit 1
fi

# ==============================================================================
# 安装依赖
# ==============================================================================
echo "==> 安装 Homebrew 依赖..."
brew install --cask font-maple-mono-nf
if [ ! -d "/Applications/Ghostty.app" ]; then
  brew install --cask ghostty
else
  echo "    Ghostty 已安装，跳过。"
fi
brew install starship fzf zoxide eza bat yazi zsh-autosuggestions zsh-syntax-highlighting zsh-completions

# ==============================================================================
# 下载配置文件
# ==============================================================================
echo "==> 下载配置文件..."
git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo"

# ==============================================================================
# 备份已有配置
# ==============================================================================
echo "==> 检查已有配置..."
backup_file() {
  local file="$1"
  local name="$2"
  if [ -e "$file" ] || [ -L "$file" ]; then
    mkdir -p "$BACKUP_DIR"
    if [ -L "$file" ]; then
      local target
      target="$(readlink "$file")"
      echo "$target" > "$BACKUP_DIR/$name.symlink"
      echo "    备份软链接 $file (指向 $target)"
    else
      cp "$file" "$BACKUP_DIR/$name"
      echo "    备份文件 $file"
    fi
  fi
}

backup_file ~/.config/ghostty/config "ghostty-config"
backup_file ~/.config/ghostty/theme.zsh "ghostty-theme.zsh"
backup_file ~/.config/starship.toml "starship.toml"

if [ -d "$BACKUP_DIR" ]; then
  echo ""
  echo "    ✓ 已有配置已备份到: $BACKUP_DIR"
  echo ""
else
  echo "    无已有配置，跳过备份。"
fi

# ==============================================================================
# 安装配置文件
# ==============================================================================
echo "==> 安装配置文件..."
mkdir -p ~/.config/ghostty

cp "$TMP_DIR/repo/ghostty/config" ~/.config/ghostty/config
cp "$TMP_DIR/repo/starship/starship.toml" ~/.config/starship.toml

# 按选择写入浅色/深色。彩虹条始终用 Mocha（粉彩底 + 深色字），浅底上也清楚。
if [[ "$THEME_VARIANT" == "light" ]]; then
  sed -i '' 's/theme = "Catppuccin Mocha"/theme = "Catppuccin Latte"/' ~/.config/ghostty/config
  cat > ~/.config/ghostty/theme.zsh <<'EOF'
# 由 ghostty-terminal-config 安装脚本生成（浅色）
# bat 使用内置浅色主题，避免深色高亮铺在浅色终端上
export BAT_THEME="GitHub"
# Catppuccin Latte overlay0，自动建议比默认灰阶更易辨认
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#9ca0b0"
EOF
else
  cat > ~/.config/ghostty/theme.zsh <<'EOF'
# 由 ghostty-terminal-config 安装脚本生成（深色）
# 沿用 bat / autosuggestions 默认配色
EOF
fi

echo "    ✓ ~/.config/ghostty/config  ($THEME_LABEL)"
echo "    ✓ ~/.config/ghostty/theme.zsh"
echo "    ✓ ~/.config/starship.toml"

# .zshrc：有标记块则整段替换（方便 M 系列 / Intel 同步更新），否则追加
zsh_snippet="$(mktemp)"
{
  echo "# >>> ghostty-terminal-config >>>"
  echo "# 以下内容由 ghostty-terminal-config 安装脚本自动追加"
  echo "# 删除方法: 移除从 >>> 到 <<< 之间的所有内容"
  cat "$TMP_DIR/repo/zsh/.zshrc"
  echo "# <<< ghostty-terminal-config <<<"
} > "$zsh_snippet"

touch ~/.zshrc
if grep -q "# >>> ghostty-terminal-config >>>" ~/.zshrc 2>/dev/null; then
  zsh_tmp="$(mktemp)"
  awk -v snippet="$zsh_snippet" '
    /# >>> ghostty-terminal-config >>>/ {
      while ((getline line < snippet) > 0) print line
      close(snippet)
      skip=1
      next
    }
    skip && /# <<< ghostty-terminal-config <<</ { skip=0; next }
    skip { next }
    { print }
  ' ~/.zshrc > "$zsh_tmp"
  mv "$zsh_tmp" ~/.zshrc
  echo "    ✓ ~/.zshrc (已更新配置块，兼容 Apple Silicon / Intel)"
else
  {
    echo ""
    cat "$zsh_snippet"
  } >> ~/.zshrc
  echo "    ✓ ~/.zshrc (已追加到尾部)"
fi
rm -f "$zsh_snippet"

# ==============================================================================
# 完成
# ==============================================================================
echo ""
echo "======================================"
echo " 安装完成！"
echo "======================================"
echo ""
echo "主题: $THEME_LABEL"
echo "请重启 Ghostty 终端生效。"
echo ""
echo "之后若要改主题，重新运行本脚本并重新选择即可。"
echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "恢复旧配置:"
  echo "  cp $BACKUP_DIR/ghostty-config ~/.config/ghostty/config"
  echo "  cp $BACKUP_DIR/starship.toml ~/.config/starship.toml"
  echo "  cp $BACKUP_DIR/ghostty-theme.zsh ~/.config/ghostty/theme.zsh"
  echo ""
fi
echo "卸载 zsh 配置:"
echo "  删除 ~/.zshrc 中 '>>> ghostty-terminal-config >>>' 到 '<<< ghostty-terminal-config <<<' 之间的所有内容"
echo ""
