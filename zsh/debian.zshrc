# ==============================================================================
# Debian 专用 zsh 配置（不要和 macOS Homebrew 那份混用）
# ==============================================================================

# Starship / 用户级二进制装在 ~/.local/bin
if [[ -d "$HOME/.local/bin" ]]; then
  case ":$PATH:" in
    *":$HOME/.local/bin:"*) ;;
    *) PATH="$HOME/.local/bin:$PATH" ;;
  esac
fi

# ==============================================================================
# 历史记录
# ==============================================================================
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space

# ==============================================================================
# zsh-completions | 补全增强
# ==============================================================================
# 安装脚本 git clone 到 ~/.zsh/zsh-completions（官方 Manual 安装）
fpath=("$HOME/.zsh/zsh-completions/src" $fpath)
autoload -Uz compinit && compinit -u
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# ==============================================================================
# Starship | 终端提示符
# ==============================================================================
# 配置文件: ~/.config/starship.toml（钉在 Starship 1.26 的官方 plain-text-symbols 预设）
eval "$(starship init zsh)"

# ==============================================================================
# fzf | 模糊搜索
# ==============================================================================
# 官方 .deb（>= 0.74.1）提供 --zsh
source <(fzf --zsh)

# ==============================================================================
# zoxide | 智能目录跳转
# ==============================================================================
eval "$(zoxide init zsh)"

# ==============================================================================
# Yazi | 终端文件管理器
# ==============================================================================
# GNU mktemp：模板作为文件路径，不用 BSD 的 -t
function y() {
  local tmp cwd
  tmp="$(mktemp "${TMPDIR:-/tmp}/yazi-cwd.XXXXXX")"
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ==============================================================================
# zsh-autosuggestions | 自动建议
# ==============================================================================
# Debian 包路径，见 zsh-autosuggestions 的 Debian 包装
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ==============================================================================
# zsh-syntax-highlighting | 语法高亮
# ==============================================================================
# 官方 INSTALL.md：Debian 上 source 这个路径，且必须放在 .zshrc 末尾附近
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ==============================================================================
# 快捷键
# ==============================================================================
bindkey '^F' autosuggest-accept

# ==============================================================================
# 别名
# ==============================================================================
alias ls="eza --group-directories-first"
alias ll="eza -l --sort=name"
alias lt="eza --tree --level=2"
# 上游 GitHub .deb 的可执行文件名是 bat（不是 Debian 主仓的 batcat）
alias cat="bat --paging=never --style=plain"
