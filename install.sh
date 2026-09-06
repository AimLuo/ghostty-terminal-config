#!/usr/bin/env bash

# ==============================================================================
# shell-config 一键安装脚本
# ==============================================================================
# 用法:
#   bash <(curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install.sh)
#
# 说明:
#   1. 安装 Homebrew 依赖（Starship + zsh 工具，不装终端模拟器，不装字体）
#   2. 备份已有 Starship 配置到 ~/.config-backup/YYYYMMDD_HHMMSS/
#   3. 安装官方 Starship plain-text-symbols 预设，并把 zsh 配置追加/替换到 ~/.zshrc
#
# 卸载 zsh 配置:
#   删除 ~/.zshrc 中 ">>> shell-config >>>" 到 "<<< shell-config <<<" 之间的内容
#   旧版标记 ">>> ghostty-terminal-config >>>" 也会被本次安装替换掉
# ==============================================================================

set -e

REPO_URL="https://github.com/AimLuo/ghostty-terminal-config.git"
BACKUP_DIR="$HOME/.config-backup/$(date +%Y%m%d_%H%M%S)"
TMP_DIR="$(mktemp -d)"
BLOCK_BEGIN="# >>> shell-config >>>"
BLOCK_END="# <<< shell-config <<<"
OLD_BLOCK_BEGIN="# >>> ghostty-terminal-config >>>"
OLD_BLOCK_END="# <<< ghostty-terminal-config <<<"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# ==============================================================================
# 用户确认
# ==============================================================================
echo ""
echo "======================================"
echo " shell-config 安装脚本"
echo "======================================"
echo ""
echo "本脚本将执行以下操作:"
echo "  1. 通过 Homebrew 安装 Starship 与 zsh 工具（不装 Ghostty，不装字体）"
echo "  2. 备份已有 Starship 配置到 ~/.config-backup/"
echo "  3. 安装 Starship plain-text 预设，并写入 zsh 配置"
echo ""
echo "已有 Starship 配置将备份到: $BACKUP_DIR"
echo "不会改动任何终端模拟器配置（包括 ~/.config/ghostty）。"
echo ""
read -p "是否继续？(y/n) " -n 1 -r < /dev/tty
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "已取消安装。"
  exit 0
fi
echo ""

# ==============================================================================
# 检查环境
# ==============================================================================
if ! command -v brew &> /dev/null; then
  echo "错误: 未检测到 Homebrew，请先安装: https://brew.sh"
  exit 1
fi

if ! command -v git &> /dev/null; then
  echo "错误: 未检测到 git，请先安装 Xcode Command Line Tools: xcode-select --install"
  exit 1
fi

# ==============================================================================
# 安装依赖
# ==============================================================================
echo "==> 安装 Homebrew 依赖..."
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

backup_file ~/.config/starship.toml "starship.toml"

if [ -d "$BACKUP_DIR" ]; then
  echo ""
  echo "    ✓ 已有配置已备份到: $BACKUP_DIR"
  echo ""
else
  echo "    无已有 Starship 配置，跳过备份。"
fi

# ==============================================================================
# 安装配置文件
# ==============================================================================
echo "==> 安装配置文件..."
mkdir -p ~/.config
cp "$TMP_DIR/repo/starship/starship.toml" ~/.config/starship.toml
echo "    ✓ ~/.config/starship.toml  (plain-text-symbols)"

write_zsh_block() {
  local dest="$1"
  {
    echo "$BLOCK_BEGIN"
    echo "# 由安装脚本追加。删除本段即可卸载 zsh 配置。"
    cat "$TMP_DIR/repo/zsh/.zshrc"
    echo "$BLOCK_END"
  } > "$dest"
}

replace_marked_block() {
  local file="$1"
  local begin="$2"
  local end="$3"
  local newfile="$4"
  local tmp
  tmp="$(mktemp)"
  awk -v begin="$begin" -v end="$end" -v newfile="$newfile" '
    BEGIN { replacing = 0 }
    $0 == begin {
      while ((getline line < newfile) > 0) print line
      close(newfile)
      replacing = 1
      next
    }
    replacing && $0 == end { replacing = 0; next }
    !replacing { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

remove_marked_block() {
  local file="$1"
  local begin="$2"
  local end="$3"
  local tmp
  tmp="$(mktemp)"
  awk -v begin="$begin" -v end="$end" '
    BEGIN { removing = 0 }
    $0 == begin { removing = 1; next }
    removing && $0 == end { removing = 0; next }
    !removing { print }
  ' "$file" > "$tmp"
  mv "$tmp" "$file"
}

strip_ghostty_theme_source() {
  local file="$1"
  if grep -q 'ghostty/theme.zsh' "$file" 2>/dev/null; then
    local tmp
    tmp="$(mktemp)"
    grep -v 'ghostty/theme.zsh' "$file" > "$tmp"
    mv "$tmp" "$file"
  fi
}

BLOCK_FILE="$TMP_DIR/zsh-block"
write_zsh_block "$BLOCK_FILE"

touch ~/.zshrc

if grep -q "$BLOCK_BEGIN" ~/.zshrc; then
  replace_marked_block ~/.zshrc "$BLOCK_BEGIN" "$BLOCK_END" "$BLOCK_FILE"
  echo "    ✓ ~/.zshrc（已更新 shell-config 段）"
elif grep -q "$OLD_BLOCK_BEGIN" ~/.zshrc; then
  replace_marked_block ~/.zshrc "$OLD_BLOCK_BEGIN" "$OLD_BLOCK_END" "$BLOCK_FILE"
  echo "    ✓ ~/.zshrc（已将旧 ghostty-terminal-config 段替换为 shell-config）"
else
  {
    echo ""
    cat "$BLOCK_FILE"
  } >> ~/.zshrc
  echo "    ✓ ~/.zshrc（已追加 shell-config 段）"
fi

if grep -q "$OLD_BLOCK_BEGIN" ~/.zshrc; then
  remove_marked_block ~/.zshrc "$OLD_BLOCK_BEGIN" "$OLD_BLOCK_END"
  echo "    ✓ ~/.zshrc（已移除残留的旧标记段）"
fi

strip_ghostty_theme_source ~/.zshrc

# ==============================================================================
# 完成
# ==============================================================================
echo ""
echo "======================================"
echo " 安装完成！"
echo "======================================"
echo ""
echo "请开一个新的 zsh 会话，或执行: source ~/.zshrc"
echo "任意终端模拟器都可以，本配置不绑定 Ghostty。"
echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "恢复旧 Starship 配置:"
  echo "  cp $BACKUP_DIR/starship.toml ~/.config/starship.toml"
  echo ""
fi
echo "卸载 zsh 配置:"
echo "  删除 ~/.zshrc 中 '$BLOCK_BEGIN' 到 '$BLOCK_END' 之间的所有内容"
echo ""
