csh() {
    # Main subcommands list from your help menu
    local subs=("shell" "toggle" "scheme" "screenshot" "record" "clipboard" "emoji" "wallpaper" "resizer")

    if [ $# -eq 0 ]; then
        echo "caelestia shell -s" | bat -l bash -pp
        caelestia shell -s | sed 's/^target //; s/function //' | bat -l ts -pp
    elif [[ " ${subs[*]} " =~ " $1 " ]]; then
        echo "caelestia $*" | bat -l bash -pp
        caelestia "$@"
    else
        echo "caelestia shell $*" | bat -l bash -pp
        caelestia shell "$@"
    fi
}


# 1. Force grouping matches by tag (CRITICAL)
zstyle ':completion:*:*:(csh|caelestia):*' group-name ''

# 2. Add headers so you can see the split (Optional but helpful)
zstyle ':completion:*:*:(csh|caelestia):*:descriptions' format '%F{white}--- %d ---%f'

# 3. Apply the actual colors (1;33 is Bold Yellow, 1;36 is Bold Cyan)
# Subcommands = Yellow
zstyle ':completion:*:*:(csh|caelestia):*:subcommands' list-colors '=(#b)(*)=1;33'
# Targets = Cyan
zstyle ':completion:*:*:(csh|caelestia):*:targets'     list-colors '=(#b)(*)=1;36'
# Functions = Magenta
zstyle ':completion:*:*:(csh|caelestia):*:functions'   list-colors '=(#b)(*)=1;35'

_caelestia_completions() {
    local -a subs targets functions
    subs=(shell toggle scheme screenshot record clipboard emoji wallpaper resizer)
    # Get targets and filter out the word 'target'
    targets=($(caelestia shell -s 2>/dev/null | awk '/^target/ {print $2}'))

    if [[ "$service" == "caelestia" ]]; then
        case $CURRENT in
            2) _describe -t subcommands 'Subcommands' subs ;;
            3) [[ "${words[2]}" == "shell" ]] && _describe -t targets 'Targets' targets ;;
            4) [[ "${words[2]}" == "shell" ]] && {
                local t="${words[3]}"
                functions=($(caelestia shell -s | sed -n "/^target $t/,/^target/p" | awk '/function/ {sub(/\(.*/, "", $2); print $2}'))
                _describe -t functions 'Functions' functions
            } ;;
        esac
    else
        case $CURRENT in
            2) 
                # These must be separate calls with distinct tags
                _describe -t subcommands 'Subcommands' subs
                _describe -t targets 'Targets' targets 
                ;;
            3) 
                if [[ "${words[2]}" == "shell" ]]; then
                     _describe -t targets 'Targets' targets
                elif [[ " ${targets[*]} " =~ " ${words[2]} " ]]; then
                     local t="${words[2]}"
                     functions=($(caelestia shell -s | sed -n "/^target $t/,/^target/p" | awk '/function/ {sub(/\(.*/, "", $2); print $2}'))
                     _describe -t functions 'Functions' functions
                fi ;;
            4) 
                if [[ "${words[2]}" == "shell" ]]; then
                     local t="${words[3]}"
                     functions=($(caelestia shell -s | sed -n "/^target $t/,/^target/p" | awk '/function/ {sub(/\(.*/, "", $2); print $2}'))
                     _describe -t functions 'Functions' functions
                fi ;;
        esac
    fi
}

compdef _caelestia_completions csh caelestia
