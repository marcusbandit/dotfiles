# unicode.sh: kitty-style unicode grid picker (upick) on ctrl+shift+u
# Note: zsh cannot distinguish ctrl+shift+u from ctrl+u (no kitty keyboard
# protocol), so the widget binds ^U. Rebind below if you want another chord.

upick-widget() {
  local out
  out=$(upick)
  local rc=$?
  zle reset-prompt
  (( rc != 0 )) && return 0
  LBUFFER+=${(j::)${(f)out}}
}
zle -N upick-widget
bindkey '^U' upick-widget
