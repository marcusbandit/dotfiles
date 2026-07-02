#compdef caelestia-patches

_caelestia-patches() {
    local -a subcmds
    subcmds=(
        'sync:Back up working copy, recopy upstream, reapply all patches'
        'apply:Apply all patches to the working copy (skips already-applied)'
        'status:Show per-patch state (applied/pending/conflict)'
        'regen:Regenerate .patch files from working copy vs upstream'
        'list:List patches and the files they touch'
        'diff:Full diff of working copy vs upstream'
        'help:Show usage'
    )
    _describe -t commands 'caelestia-patches command' subcmds
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
    _caelestia-patches "$@"
else
    compdef _caelestia-patches caelestia-patches
fi
