#!/usr/bin/env bash

# ==============================================================================
# shell-config macOS 安装脚本
# ==============================================================================
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install-macos.sh | bash
#
# 说明:
#   1. 安装 Homebrew 依赖（Starship + zsh 工具，不装终端模拟器，不装字体）
#   2. 备份已有 Starship 配置到 ~/.config-backup/YYYYMMDD_HHMMSS/
#   3. 安装 Starship 1.26 预设与 zshenv/、zshrc/ 到 ~/.config/shell-config/
#   4. 在 ~/.zshenv 和 ~/.zshrc 写入 shell-config 段（不设置 ZDOTDIR）
#
# 卸载 zsh 配置:
#   删除 ~/.zshenv 和 ~/.zshrc 中 ">>> shell-config >>>" 到 "<<< shell-config <<<" 之间的内容
#   并删除 ~/.config/shell-config
# ==============================================================================

set -e

REPO_URL="https://github.com/AimLuo/ghostty-terminal-config.git"
STARSHIP_PRESET_VERSION="1.26.0"
SHELL_CONFIG_DIR="$HOME/.config/shell-config"
SHELL_CONFIG_ZSHENV="$SHELL_CONFIG_DIR/zshenv"
SHELL_CONFIG_ZSHRC="$SHELL_CONFIG_DIR/zshrc"
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
echo "  3. 安装 Starship ${STARSHIP_PRESET_VERSION} 预设与 $SHELL_CONFIG_ZSHENV、$SHELL_CONFIG_ZSHRC"
echo "  4. 在 ~/.zshenv 和 ~/.zshrc 写入 shell-config 段"
echo ""
echo "Starship 配置钉在 ${STARSHIP_PRESET_VERSION}（来自该版本的 starship preset），"
echo "不会使用 GitHub main 或 starship.rs 上尚未发版的文档。"
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

STARSHIP_VER="$(starship --version 2>/dev/null | awk 'NR==1 {print $2}')"
echo "    已安装 Starship ${STARSHIP_VER:-unknown}"
echo "    即将写入的配置是 Starship ${STARSHIP_PRESET_VERSION} 的 plain-text-symbols 预设"
if [[ -n "$STARSHIP_VER" && "$STARSHIP_VER" != "$STARSHIP_PRESET_VERSION" && "$STARSHIP_VER" != ${STARSHIP_PRESET_VERSION%.*}.* ]]; then
  echo "    注意: 当前 Starship 是 ${STARSHIP_VER}，与仓库钉住的 ${STARSHIP_PRESET_VERSION} 不一致"
fi

# ==============================================================================
# 定位配置文件（本地仓库优先，否则 clone GitHub）
# ==============================================================================
SRC=""
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [[ -n "$SCRIPT_PATH" && -f "$SCRIPT_PATH" ]]; then
  _dir="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  if [[ -f "$_dir/starship/starship.toml" && -f "$_dir/zshenv/env.zsh" && -f "$_dir/zshrc/main.zsh" ]]; then
    SRC="$_dir"
    echo "==> 使用本地仓库: $SRC"
  fi
fi
if [[ -z "$SRC" ]]; then
  echo "==> 下载配置文件..."
  git clone --depth 1 "$REPO_URL" "$TMP_DIR/repo"
  SRC="$TMP_DIR/repo"
fi

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
mkdir -p "$SHELL_CONFIG_ZSHENV" "$SHELL_CONFIG_ZSHRC" ~/.local/state/zsh ~/.cache/zsh
rm -rf "$SHELL_CONFIG_DIR/zsh"

cp "$SRC/zshenv/"*.zsh "$SHELL_CONFIG_ZSHENV/"
cp "$SRC/zshrc/"*.zsh "$SHELL_CONFIG_ZSHRC/"
cp "$SRC/starship/starship.toml" ~/.config/starship.toml
echo "    ✓ $SHELL_CONFIG_ZSHENV"
echo "    ✓ $SHELL_CONFIG_ZSHRC"
echo "    ✓ ~/.config/starship.toml  (Starship ${STARSHIP_PRESET_VERSION} plain-text-symbols)"

write_zshenv_block() {
  local dest="$1"
  {
    echo "$BLOCK_BEGIN"
    echo "# 由安装脚本写入。删除本段并移除 ~/.config/shell-config 即可卸载。"
    echo '[[ -f "$HOME/.config/shell-config/zshenv/env.zsh" ]] && source "$HOME/.config/shell-config/zshenv/env.zsh"'
    echo "$BLOCK_END"
  } > "$dest"
}

write_zshrc_block() {
  local dest="$1"
  {
    echo "$BLOCK_BEGIN"
    echo "# 由安装脚本写入。删除本段并移除 ~/.config/shell-config 即可卸载。"
    echo '[[ -f "$HOME/.config/shell-config/zshrc/main.zsh" ]] && source "$HOME/.config/shell-config/zshrc/main.zsh"'
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
  if ! awk -v begin="$begin" -v end="$end" -v newfile="$newfile" '
    BEGIN { replacing = 0 }
    $0 == begin {
      while ((getline line < newfile) > 0) print line
      close(newfile)
      replacing = 1
      next
    }
    replacing && $0 == end { replacing = 0; next }
    !replacing { print }
    END { if (replacing) exit 1 }
  ' "$file" > "$tmp"; then
    echo "错误: $file 有 '${begin}' 但缺少 '${end}'，未改写该文件" >&2
    rm -f "$tmp"
    return 1
  fi
  mv "$tmp" "$file"
}

remove_marked_block() {
  local file="$1"
  local begin="$2"
  local end="$3"
  local tmp
  tmp="$(mktemp)"
  if ! awk -v begin="$begin" -v end="$end" '
    BEGIN { removing = 0 }
    $0 == begin { removing = 1; next }
    removing && $0 == end { removing = 0; next }
    !removing { print }
    END { if (removing) exit 1 }
  ' "$file" > "$tmp"; then
    echo "错误: $file 有 '${begin}' 但缺少 '${end}'，未改写该文件" >&2
    rm -f "$tmp"
    return 1
  fi
  mv "$tmp" "$file"
}

apply_marked_block() {
  local file="$1"
  local block="$2"
  touch "$file"
  if grep -q "$BLOCK_BEGIN" "$file"; then
    replace_marked_block "$file" "$BLOCK_BEGIN" "$BLOCK_END" "$block"
    echo "    ✓ $file（已更新 shell-config 段）"
  else
    {
      echo ""
      cat "$block"
    } >> "$file"
    echo "    ✓ $file（已追加 shell-config 段）"
  fi
  if grep -q "$OLD_BLOCK_BEGIN" "$file"; then
    remove_marked_block "$file" "$OLD_BLOCK_BEGIN" "$OLD_BLOCK_END"
    echo "    ✓ $file（已移除 ghostty-terminal-config 旧段）"
  fi
}

ZSHENV_BLOCK="$TMP_DIR/zshenv-block"
ZSHRC_BLOCK="$TMP_DIR/zshrc-block"
write_zshenv_block "$ZSHENV_BLOCK"
write_zshrc_block "$ZSHRC_BLOCK"

apply_marked_block ~/.zshenv "$ZSHENV_BLOCK"
apply_marked_block ~/.zshrc "$ZSHRC_BLOCK"

# ==============================================================================
# 完成
# ==============================================================================
echo ""
echo "======================================"
echo " 安装完成！"
echo "======================================"
echo ""
echo "请开一个新的 zsh 会话（环境变量在 ~/.zshenv，source ~/.zshrc 不会重载它们）。"
echo "任意终端模拟器都可以，本配置不绑定 Ghostty。"
echo "Starship 配置为 ${STARSHIP_PRESET_VERSION} 的 plain-text-symbols 预设。"
echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "恢复旧 Starship 配置:"
  echo "  cp $BACKUP_DIR/starship.toml ~/.config/starship.toml"
  echo ""
fi
echo "卸载 zsh 配置:"
echo "  删除 ~/.zshenv 和 ~/.zshrc 中 '$BLOCK_BEGIN' 到 '$BLOCK_END' 之间的内容"
echo "  rm -rf ~/.config/shell-config"
echo ""
