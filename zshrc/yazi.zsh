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
