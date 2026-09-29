HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
mkdir -p "$(dirname "$HISTFILE")" 2>/dev/null

setopt share_history
setopt hist_ignore_all_dups
setopt hist_ignore_space
