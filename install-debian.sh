#!/usr/bin/env bash

# ==============================================================================
# shell-config Debian 安装脚本（面向 Debian 13 Trixie）
# ==============================================================================
# 用法:
#   bash <(curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install-debian.sh)
#
# 前提: 已安装 git 和 zsh。
#
# 说明:
#   1. Debian 主仓安装 eza 与 zsh 插件；bat / zoxide / fzf / yazi 下官方 GitHub .deb
#   2. Starship 无官方 .deb，用官方 install.sh 钉在 1.26.0
#   3. 写入 Starship 1.26 预设，以及 Debian 专用 zsh/debian.zshrc
#   不加第三方 apt 源，不装字体，不改终端模拟器配置
# ==============================================================================

set -euo pipefail

REPO_URL="https://github.com/AimLuo/ghostty-terminal-config.git"
STARSHIP_PRESET_VERSION="1.26.0"
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
echo " shell-config Debian 安装脚本"
echo "======================================"
echo ""
echo "本脚本面向 Debian 13 (Trixie)，将执行:"
echo "  1. apt 安装 eza、zsh-autosuggestions、zsh-syntax-highlighting、file、curl"
echo "  2. 从 GitHub Releases 下载官方 .deb：bat、zoxide、fzf、yazi"
echo "  3. 用官方脚本安装 Starship ${STARSHIP_PRESET_VERSION} 到 ~/.local/bin"
echo "  4. git clone zsh-completions 到 ~/.zsh/zsh-completions"
echo "  5. 备份已有 Starship 配置，写入 1.26 预设和 Debian 专用 zsh 配置"
echo ""
echo "Starship 配置钉在 ${STARSHIP_PRESET_VERSION}。"
echo "不加第三方 apt 源，不装字体，不改终端模拟器配置。"
echo "已有 Starship 配置将备份到: $BACKUP_DIR"
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
if [[ ! -f /etc/os-release ]]; then
  echo "错误: 找不到 /etc/os-release，无法确认是否为 Debian。"
  exit 1
fi
# shellcheck source=/dev/null
. /etc/os-release
if [[ "${ID:-}" != debian ]]; then
  echo "错误: 这是 Debian 安装脚本，当前系统 ID=${ID:-unknown}"
  exit 1
fi
if [[ "${VERSION_ID:-}" != 13 ]]; then
  echo "注意: 本脚本按 Debian 13 (Trixie) 编写，当前 VERSION_ID=${VERSION_ID:-unknown}"
  echo ""
fi

if ! command -v git &> /dev/null; then
  echo "错误: 未检测到 git。请先安装: sudo apt install git"
  exit 1
fi
if ! command -v zsh &> /dev/null; then
  echo "错误: 未检测到 zsh。请先安装: sudo apt install zsh"
  exit 1
fi
if ! command -v sudo &> /dev/null; then
  echo "错误: 未检测到 sudo。"
  exit 1
fi
if ! command -v dpkg &> /dev/null; then
  echo "错误: 未检测到 dpkg。"
  exit 1
fi

DEB_ARCH="$(dpkg --print-architecture)"
case "$DEB_ARCH" in
  amd64)
    YAZI_ASSET='yazi-x86_64-unknown-linux-gnu\.deb$'
    BAT_ASSET='/bat_[0-9][^/]*_amd64\.deb$'
    ZOXIDE_ASSET='/zoxide_[^/]*_amd64\.deb$'
    FZF_ASSET='/fzf_[^/]*_amd64\.deb$'
    ;;
  arm64)
    YAZI_ASSET='yazi-aarch64-unknown-linux-gnu\.deb$'
    BAT_ASSET='/bat_[0-9][^/]*_arm64\.deb$'
    ZOXIDE_ASSET='/zoxide_[^/]*_arm64\.deb$'
    FZF_ASSET='/fzf_[^/]*_arm64\.deb$'
    ;;
  *)
    echo "错误: 不支持的架构 ${DEB_ARCH}（需要 amd64 或 arm64）"
    exit 1
    ;;
esac

github_latest_asset() {
  local repo="$1"
  local pattern="$2"
  local url
  url="$(curl -fsSL --retry 3 --retry-delay 1 -A "shell-config" \
    "https://api.github.com/repos/${repo}/releases/latest" \
    | tr '"' '\n' \
    | grep -E '^https://github.com/.*/releases/download/' \
    | grep -E "$pattern" \
    | head -1)"
  if [[ -z "$url" ]]; then
    echo "错误: 在 ${repo} 的 latest release 里找不到匹配 ${pattern} 的资源" >&2
    return 1
  fi
  printf '%s\n' "$url"
}

install_github_deb() {
  local name="$1"
  local repo="$2"
  local pattern="$3"
  local url dest
  url="$(github_latest_asset "$repo" "$pattern")"
  dest="$TMP_DIR/${name}.deb"
  echo "    下载 ${url}"
  curl -fL --retry 3 -A "shell-config" -o "$dest" "$url"
  sudo apt install -y "$dest"
  echo "    ✓ ${name}"
}

# ==============================================================================
# apt：没有上游官方 .deb 的包
# ==============================================================================
echo "==> apt 更新并安装 Debian 主仓软件包..."
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  curl \
  file \
  eza \
  zsh-autosuggestions \
  zsh-syntax-highlighting

# ==============================================================================
# 官方 GitHub .deb：bat / zoxide / fzf / yazi
# ==============================================================================
echo "==> 从 GitHub Releases 安装官方 .deb (${DEB_ARCH})..."
install_github_deb bat sharkdp/bat "$BAT_ASSET"
install_github_deb zoxide ajeetdsouza/zoxide "$ZOXIDE_ASSET"
install_github_deb fzf junegunn/fzf "$FZF_ASSET"
install_github_deb yazi sxyazi/yazi "$YAZI_ASSET"

# ==============================================================================
# Starship：无官方 .deb，用官方 install.sh 钉 1.26.0
# ==============================================================================
echo "==> 安装 Starship ${STARSHIP_PRESET_VERSION}（官方 install.sh，无 .deb）..."
mkdir -p "$HOME/.local/bin"
curl -sS https://starship.rs/install.sh | sh -s -- -y -v "v${STARSHIP_PRESET_VERSION}" -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
STARSHIP_VER="$(starship --version 2>/dev/null | awk 'NR==1 {print $2}')"
echo "    已安装 Starship ${STARSHIP_VER:-unknown}"
echo "    即将写入的配置是 Starship ${STARSHIP_PRESET_VERSION} 的 plain-text-symbols 预设"
if [[ -n "${STARSHIP_VER:-}" && "$STARSHIP_VER" != "$STARSHIP_PRESET_VERSION" && "$STARSHIP_VER" != ${STARSHIP_PRESET_VERSION%.*}.* ]]; then
  echo "    注意: 当前 Starship 是 ${STARSHIP_VER}，与仓库钉住的 ${STARSHIP_PRESET_VERSION} 不一致"
fi

# ==============================================================================
# zsh-completions：官方 Manual 安装
# ==============================================================================
echo "==> 安装 zsh-completions..."
mkdir -p "$HOME/.zsh"
if [[ -d "$HOME/.zsh/zsh-completions/.git" ]]; then
  git -C "$HOME/.zsh/zsh-completions" pull --ff-only
  echo "    ✓ 已更新 ~/.zsh/zsh-completions"
else
  git clone --depth 1 https://github.com/zsh-users/zsh-completions.git "$HOME/.zsh/zsh-completions"
  echo "    ✓ 已克隆 ~/.zsh/zsh-completions"
fi

# ==============================================================================
# 定位配置文件（本地仓库优先，否则 clone GitHub）
# ==============================================================================
SRC=""
SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [[ -n "$SCRIPT_PATH" && -f "$SCRIPT_PATH" ]]; then
  _dir="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  if [[ -f "$_dir/starship/starship.toml" && -f "$_dir/zsh/debian.zshrc" ]]; then
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
mkdir -p ~/.config
cp "$SRC/starship/starship.toml" ~/.config/starship.toml
echo "    ✓ ~/.config/starship.toml  (Starship ${STARSHIP_PRESET_VERSION} plain-text-symbols)"

write_zsh_block() {
  local dest="$1"
  {
    echo "$BLOCK_BEGIN"
    echo "# 由 Debian 安装脚本追加。删除本段即可卸载 zsh 配置。"
    cat "$SRC/zsh/debian.zshrc"
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

BLOCK_FILE="$TMP_DIR/zsh-block"
write_zsh_block "$BLOCK_FILE"

touch ~/.zshrc

if grep -q "$BLOCK_BEGIN" ~/.zshrc; then
  replace_marked_block ~/.zshrc "$BLOCK_BEGIN" "$BLOCK_END" "$BLOCK_FILE"
  echo "    ✓ ~/.zshrc（已更新 shell-config 段，Debian 配置）"
elif grep -q "$OLD_BLOCK_BEGIN" ~/.zshrc; then
  replace_marked_block ~/.zshrc "$OLD_BLOCK_BEGIN" "$OLD_BLOCK_END" "$BLOCK_FILE"
  echo "    ✓ ~/.zshrc（已将旧 ghostty-terminal-config 段替换为 Debian shell-config）"
else
  {
    echo ""
    cat "$BLOCK_FILE"
  } >> ~/.zshrc
  echo "    ✓ ~/.zshrc（已追加 Debian shell-config 段）"
fi

if grep -q "$OLD_BLOCK_BEGIN" ~/.zshrc; then
  remove_marked_block ~/.zshrc "$OLD_BLOCK_BEGIN" "$OLD_BLOCK_END"
  echo "    ✓ ~/.zshrc（已移除残留的旧标记段）"
fi

# ==============================================================================
# 完成
# ==============================================================================
echo ""
echo "======================================"
echo " 安装完成！"
echo "======================================"
echo ""
echo "请开一个新的 zsh 会话，或执行: source ~/.zshrc"
echo "若当前登录 shell 还不是 zsh: chsh -s /usr/bin/zsh"
echo "Starship 配置为 ${STARSHIP_PRESET_VERSION} 的 plain-text-symbols 预设。"
echo "zsh 配置来自 zsh/debian.zshrc，不是 macOS 那份。"
echo ""
if [ -d "$BACKUP_DIR" ]; then
  echo "恢复旧 Starship 配置:"
  echo "  cp $BACKUP_DIR/starship.toml ~/.config/starship.toml"
  echo ""
fi
echo "卸载 zsh 配置:"
echo "  删除 ~/.zshrc 中 '$BLOCK_BEGIN' 到 '$BLOCK_END' 之间的所有内容"
echo ""
