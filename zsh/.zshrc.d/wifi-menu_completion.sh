#compdef wifi-menu

# Completion for the `wifi-menu` GUI picker (~/bin/wifi-menu).
# It takes no network arguments; only a couple of flags.

_wifi-menu() {
    _arguments \
        '(--help -h)'{--help,-h}'[Show help]' \
        '--print[Print generated menu entries and exit (no GUI)]'
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
    _wifi-menu "$@"
else
    compdef _wifi-menu wifi-menu
fi
