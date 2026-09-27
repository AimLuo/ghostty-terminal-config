# Tab 补全（macOS Homebrew 或 Debian 手动 clone 的 zsh-completions）

if [[ -n "${HOMEBREW_PREFIX:-}" && -d "$HOMEBREW_PREFIX/share/zsh-completions" ]]; then
  fpath=("$HOMEBREW_PREFIX/share/zsh-completions" $fpath)
elif [[ -d "$HOME/.zsh/zsh-completions/src" ]]; then
  fpath=("$HOME/.zsh/zsh-completions/src" $fpath)
fi

autoload -Uz compinit
mkdir -p "${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
compinit -u -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
