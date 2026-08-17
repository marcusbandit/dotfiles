# misc fun helpers

# GLaDOS credits songs: bare `portal` lists them, `portal <name>` plays one
#  Each entry is "game|title|command"; the lookup key is derived from the title
#  (lowercased, spaces to hyphens), so adding a row here is the only edit needed.
portal() {
    emulate -L zsh
    local -a songs=(
        'Portal|Still Alive|still_alive'
        'Portal 2|Want You Gone|want_you_gone'
    )

    local entry key
    local -a f
    local -i gw=0 tw=0
    for entry in $songs; do
        f=("${(@s:|:)entry}")
        (( ${#f[1]} > gw )) && gw=${#f[1]}
        (( ${#f[2]} > tw )) && tw=${#f[2]}
    done
    (( gw += 4, tw += 4 ))

    if (( $# )); then
        local q=${${(L)1}//[ _]/-}
        shift
        local -i i=0
        for entry in $songs; do
            f=("${(@s:|:)entry}")
            key=${${(L)f[2]}// /-}
            (( i++ ))
            if [[ $q == $i || $key == ${q}* || $f[3] == ${q}* ]]; then
                command $f[3] "$@"
                return
            fi
        done
        print -u2 -P "%F{red}portal:%f no song matching '$q'"
        portal
        return 1
    fi

    for entry in $songs; do
        f=("${(@s:|:)entry}")
        key=${${(L)f[2]}// /-}
        print -P "%F{cyan}${(r:$gw:)f[1]}%f%F{yellow}${(r:$tw:)f[2]}%f%F{242}portal $key%f"
    done
}

_portal() {
    local -a keys=(
        'still-alive:Portal - GLaDOS credits'
        'want-you-gone:Portal 2 - GLaDOS credits'
    )
    _describe 'song' keys
}
(( $+functions[compdef] )) && compdef _portal portal
