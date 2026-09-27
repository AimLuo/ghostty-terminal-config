# Yazi | 终端文件管理器（y：退出后 cd 到浏览目录）

function y() {
  local tmp cwd
  if [[ "$(uname -s)" == "Darwin" ]]; then
    tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  else
    tmp="$(mktemp "${TMPDIR:-/tmp}/yazi-cwd.XXXXXX")"
  fi
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
