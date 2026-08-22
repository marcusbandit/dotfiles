# Name the tmux window after the command running in it.
# Worker: ~/.claude/hooks/tmux-cmd-name.sh (see the header there for the rules).
# preexec hands it the command line; precmd hands the window back to tmux.

_TCN_HOOK="$HOME/.claude/hooks/tmux-cmd-name.sh"

if [[ -x "$_TCN_HOOK" ]]; then
    autoload -Uz add-zsh-hook

    _tmux_cmd_name_preexec() {
        [[ -n "$TMUX" ]] || return
        ( "$_TCN_HOOK" begin "$1" >/dev/null 2>&1 &! ) 2>/dev/null
    }

    _tmux_cmd_name_precmd() {
        [[ -n "$TMUX" ]] || return
        # Only pay for this when a rename actually happened for this pane.
        local gen="${XDG_RUNTIME_DIR:-/tmp}/tmux-cmdname-${UID}/${TMUX_PANE//[^a-zA-Z0-9]/_}.gen"
        [[ -e "$gen" ]] || return
        ( "$_TCN_HOOK" end >/dev/null 2>&1 &! ) 2>/dev/null
    }

    add-zsh-hook preexec _tmux_cmd_name_preexec
    add-zsh-hook precmd _tmux_cmd_name_precmd
fi
