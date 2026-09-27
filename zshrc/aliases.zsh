# eza 替代 ls；不开 --icons，避免依赖 Nerd Font
alias ls="eza --group-directories-first"   # 目录优先
alias ll="eza -l --sort=name"              # 详细列表
alias lt="eza --tree --level=2"            # 两层树形

# bat 替代 cat；--paging=never 不分页，--style=plain 去掉行号等装饰
alias cat="bat --paging=never --style=plain"
alias as="cd ~/agent-space"
alias home="cd ~"
alias c="clear"
alias g="git"

alias b="bun"
alias br="bun run"
alias n="npm"
alias nr="npm run"
alias p="pnpm"
alias pr="pnpm run"

alias h="herdr"

