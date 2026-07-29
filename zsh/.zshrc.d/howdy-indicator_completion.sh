#compdef howdy-indicator

_howdy-indicator() {
    local -a commands
    commands=(
        'watch:Watch the IR camera and show/hide the pill on open/close'
        'show:Show the face-scan pill now'
        'hide:Hide the face-scan pill now'
        'toggle:Toggle the face-scan pill'
        'test:Show the pill for 3 seconds, then hide it'
        'status:Show the state of the systemd user service'
        'help:Show usage'
    )
    _describe 'command' commands
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
    _howdy-indicator "$@"
else
    compdef _howdy-indicator howdy-indicator
fi
