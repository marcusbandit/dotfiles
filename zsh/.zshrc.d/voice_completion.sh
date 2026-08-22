#compdef voice

_voice() {
    local -a subcommands languages
    subcommands=(
        'start:begin listening (held key press)'
        'stop:stop listening and flush the final phrase'
        'toggle:flip listening state'
        'retype:type the last transcription again'
        'status:show daemon, Chrome and engine state'
        'lang:set the recognition language'
        'backend:switch speech engine (whisper or chrome)'
        'up:start the background service'
        'down:stop the background service'
        'restart:restart the background service'
        'logs:follow the daemon log'
        'debug:open a visible test page (types nothing)'
        'help:show usage'
        '--help:show usage'
        '-h:show usage'
    )

    # Mirrors the LANGUAGES table in ~/bin/voice-daemon. Any raw BCP-47 tag also
    # works, so this is a convenience list rather than a closed set.
    languages=(
        'da:Danish (da-DK)'
        'en-dk:English, Denmark (en-DK)'
        'en:English, US (en-US)'
        'en-gb:English, UK (en-GB)'
        'de:German (de-DE)'
        'sv:Swedish (sv-SE)'
        'no:Norwegian Bokmal (nb-NO)'
        'auto:detect the language automatically'
    )
    local -a backends
    backends=(
        'whisper:local Whisper large-v3-turbo, accurate and private'
        'chrome:Google Web Speech via hidden Chrome, weaker'
    )

    if (( CURRENT == 2 )); then
        _describe 'command' subcommands
    elif (( CURRENT == 3 )) && [[ $words[2] == lang ]]; then
        _describe 'language' languages
    elif (( CURRENT == 3 )) && [[ $words[2] == backend ]]; then
        _describe 'backend' backends
    fi
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
    # autoloaded from fpath — call directly
    _voice "$@"
else
    # sourced from ~/.zshrc.d — register for later
    compdef _voice voice
fi
