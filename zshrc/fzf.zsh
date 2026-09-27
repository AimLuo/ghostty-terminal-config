# fzf：Ctrl+R 历史、Ctrl+T 文件、**<Tab> 补全

if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi
