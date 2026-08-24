#compdef sudo_claude

_sudo_claude() {
    local -a subcommands
    subcommands=(
        'pending:list scripts currently in sudo_pending/'
        'archive:list previously-run (archived) scripts'
        'help:show usage'
        '--help:show usage'
        '-h:show usage'
    )

    if (( CURRENT == 2 )); then
        _describe 'command' subcommands
    fi
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
    # autoloaded from fpath — call directly
    _sudo_claude "$@"
else
    # sourced from ~/.zshrc.d — register for later
    compdef _sudo_claude sudo_claude
fi
