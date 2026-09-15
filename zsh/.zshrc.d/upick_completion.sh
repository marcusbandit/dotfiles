#compdef upick

_upick() {
  _arguments \
    '--single[exit after one pick, disable multi-select]' \
    '--help[show help]' \
    '*:initial search query:_message "search query"'
}

compdef _upick upick
