# zsh completion for nagare
_nagare() {
  local -a opts
  opts=(
    '(-p --port)'{-p,--port}'[port to listen on]:port:(8737 8080 9000)'
    '(-H --host)'{-H,--host}'[address to bind]:host:(127.0.0.1 0.0.0.0 localhost)'
    '(-d --dir)'{-d,--dir}'[library directory]:directory:_files -/'
    '(-q --quality)'{-q,--quality}'[default quality]:quality:(2160 1440 1080 720 best audio)'
    '(-j --jobs)'{-j,--jobs}'[concurrent downloads]:count:(1 2 3 4)'
    '(-n --no-open)'{-n,--no-open}'[do not open a browser]'
    '(-h --help)'{-h,--help}'[show help]'
  )
  _arguments -s $opts
}
compdef _nagare nagare
