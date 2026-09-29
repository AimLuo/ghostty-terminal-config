#!/usr/bin/env bash

# ==============================================================================
# shell-config Debian 安装脚本（面向 Debian 13 Trixie）
# ==============================================================================
# 用法:
#   curl -fsSL https://raw.githubusercontent.com/AimLuo/ghostty-terminal-config/main/install-debian.sh | bash
#
# 前提: 已安装 git 和 zsh。
#
# 说明:
#   1. Debian 主仓安装 eza 与 zsh 插件；bat / zoxide / fzf / yazi 下官方 GitHub .deb
#   2. 查 GitHub latest release，用官方 install.sh 安装 Starship
#   3. 从同一 tag 拉取 plain-text-symbols 预设；zshenv/、zshrc/ 安装到 ~/.config/shell-config/
#   4. 在 ~/.zshenv 和 ~/.zshrc 写入 shell-config 段
# ==============================================================================

set -euo pipefail

REPO_URL="https://github.com/AimLuo/ghostty-terminal-config.git"
STARSHIP_PRESET_NAME="plain-text-symbols"
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
echo " shell-config Debian 安装脚本"
echo "======================================"
echo ""
echo "本脚本面向 Debian 13 (Trixie)，将执行:"
echo "  1. apt 安装 eza、zsh-autosuggestions、zsh-syntax-highlighting、file、curl"
echo "  2. 从 GitHub Releases 下载官方 .deb：bat、zoxide、fzf、yazi"
echo "  3. 查询 GitHub 上 Starship 最新 release，用官方 install.sh 装到 ~/.local/bin"
echo "  4. 从同一 tag 拉取 ${STARSHIP_PRESET_NAME} 预设"
echo "  5. git clone zsh-completions 到 ~/.zsh/zsh-completions"
echo "  6. 备份已有 Starship 配置，写入 zsh 配置"
echo ""
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

github_latest_tag() {
  local repo="$1"
  local tag
  tag="$(curl -fsSL --retry 3 --retry-delay 1 -A "shell-config" \
    "https://api.github.com/repos/${repo}/releases/latest" \
    | grep -oE '"tag_name"[[:space:]]*:[[:space:]]*"[^"]+"' \
    | head -1 \
    | cut -d'"' -f4)"
  if [[ ! "$tag" =~ ^v?[0-9]+\.[0-9]+ ]]; then
    echo "错误: 无法从 ${repo} 解析 latest release tag（得到: ${tag:-empty}）" >&2
    return 1
  fi
  printf '%s\n' "$tag"
}

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

fetch_starship_preset() {
  local ver="$1"
  local dest="$2"
  local tag="v${ver#v}"
  local tmp="$TMP_DIR/${STARSHIP_PRESET_NAME}.toml"
  local paths=(
    "docs/public/presets/toml/${STARSHIP_PRESET_NAME}.toml"
    "docs/.vuepress/public/presets/toml/${STARSHIP_PRESET_NAME}.toml"
  )
  local path url fetched=""

  if [[ -z "$ver" ]]; then
    echo "错误: 无法确定 Starship 版本，不能下载预设" >&2
    return 1
  fi

  mkdir -p "$(dirname "$dest")"
  for path in "${paths[@]}"; do
    url="https://raw.githubusercontent.com/starship/starship/${tag}/${path}"
    echo "    下载 ${url}"
    if curl -fsSL --retry 3 --retry-delay 1 -A "shell-config" -o "$tmp" "$url" \
      && [[ -s "$tmp" ]] \
      && grep -q 'success_symbol' "$tmp"; then
      fetched="$url"
      break
    fi
    rm -f "$tmp"
  done

  if [[ -z "$fetched" ]]; then
    echo "错误: GitHub tag ${tag} 没有 ${STARSHIP_PRESET_NAME} 预设" >&2
    return 1
  fi

  {
    echo "# Official Starship preset: ${STARSHIP_PRESET_NAME}"
    echo "# Source: ${fetched}"
    echo "# Installed Starship: ${ver}"
    echo ""
    cat "$tmp"
  } > "$dest"
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
# Starship
# ==============================================================================
echo "==> 查询 Starship 最新版本..."
STARSHIP_TAG="$(github_latest_tag starship/starship)"
STARSHIP_INSTALL_VERSION="${STARSHIP_TAG#v}"
echo "    GitHub latest: ${STARSHIP_TAG}"
echo "==> 安装 Starship ${STARSHIP_INSTALL_VERSION}..."
mkdir -p "$HOME/.local/bin"
curl -sS https://starship.rs/install.sh | sh -s -- -y -v "$STARSHIP_TAG" -b "$HOME/.local/bin"
export PATH="$HOME/.local/bin:$PATH"
STARSHIP_VER="$(starship --version 2>/dev/null | awk 'NR==1 {print $2}')"
STARSHIP_VER="${STARSHIP_VER#v}"
if [[ -z "$STARSHIP_VER" ]]; then
  echo "错误: 无法读取 starship --version，不能按版本拉取预设"
  exit 1
fi
echo "    已安装 Starship ${STARSHIP_VER}"
if [[ "$STARSHIP_VER" != "$STARSHIP_INSTALL_VERSION" ]]; then
  echo "    注意: 已安装版本 ${STARSHIP_VER} 与查询到的 ${STARSHIP_INSTALL_VERSION} 不一致，将按已安装版本拉取预设"
fi

# ==============================================================================
# zsh-completions
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
  if [[ -f "$_dir/zshenv/env.zsh" && -f "$_dir/zshrc/main.zsh" ]]; then
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
fetch_starship_preset "$STARSHIP_VER" ~/.config/starship.toml
echo "    ✓ $SHELL_CONFIG_ZSHENV"
echo "    ✓ $SHELL_CONFIG_ZSHRC"
echo "    ✓ ~/.config/starship.toml  (Starship ${STARSHIP_VER} ${STARSHIP_PRESET_NAME})"

write_zshenv_block() {
  local dest="$1"
  {
    echo "$BLOCK_BEGIN"
    echo "# 由 Debian 安装脚本写入。删除本段并移除 ~/.config/shell-config 即可卸载。"
    echo '[[ -f "$HOME/.config/shell-config/zshenv/env.zsh" ]] && source "$HOME/.config/shell-config/zshenv/env.zsh"'
    echo "$BLOCK_END"
  } > "$dest"
}

write_zshrc_block() {
  local dest="$1"
  {
    echo "$BLOCK_BEGIN"
    echo "# 由 Debian 安装脚本写入。删除本段并移除 ~/.config/shell-config 即可卸载。"
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
echo "若当前登录 shell 还不是 zsh: chsh -s /usr/bin/zsh"
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
