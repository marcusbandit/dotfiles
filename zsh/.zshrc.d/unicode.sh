# unicode.sh: kitty-style unicode character picker on Ctrl+Shift+U (fzf)
# Note: zsh cannot distinguish ctrl+shift+u from ctrl+u (no kitty keyboard
# protocol), so the widget binds ^U. Rebind below if you want another chord.
# List format (tab separated): U+HEX <glyph> NAME

_unicode_cache() {
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/unicode-list.txt"
  if [[ ! -s $cache ]]; then
    mkdir -p "${cache:h}"
    python3 - "$cache" <<'PYEOF'
import sys, unicodedata
with open(sys.argv[1], "w", encoding="utf-8") as f:
    for cp in range(0x110000):
        c = chr(cp)
        if c in "\n\r":
            continue
        try:
            name = unicodedata.name(c)
        except ValueError:
            continue
        f.write(f"U+{cp:04X}\t{c}\t{name}\n")
PYEOF
  fi
  print -r -- $cache
}

fzf-unicode() {
  local cache sel hex code
  cache=$(_unicode_cache)
  sel=$(fzf --multi --reverse --height=50% --tabstop=4 \
    --prompt="unicode (hex or name): " \
    --delimiter=$'\t' \
    --preview='python3 -c "import sys; c=chr(int(sys.argv[1][2:],16)); print(\"  \"+c); print(\"  \"+sys.argv[1])" {1}' \
    --preview-window=up:5:wrap \
    < "$cache" | cut -f1) || { zle reset-prompt; return 0 }
  zle reset-prompt
  for entry in ${(f)sel}; do
    hex=${entry#U+}
    code=$((16#$hex))
    LBUFFER+=${(#)code}
  done
}
zle -N fzf-unicode
bindkey '^U' fzf-unicode
