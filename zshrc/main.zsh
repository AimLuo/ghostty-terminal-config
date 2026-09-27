# 交互式 zsh（由 ~/.zshrc 的 shell-config 段 source）

ZSHRC_DIR="$HOME/.config/shell-config/zshrc"

# ==============================================================================
# 历史记录
# ==============================================================================
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")" 2>/dev/null

setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space

# ==============================================================================
# zoxide | 智能目录跳转
# ==============================================================================
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# ==============================================================================
# 模块
# ==============================================================================
source "$ZSHRC_DIR/completion.zsh"
source "$ZSHRC_DIR/fzf.zsh"
source "$ZSHRC_DIR/yazi.zsh"
source "$ZSHRC_DIR/aliases.zsh"
source "$ZSHRC_DIR/plugins.zsh"
source "$ZSHRC_DIR/prompt.zsh"
