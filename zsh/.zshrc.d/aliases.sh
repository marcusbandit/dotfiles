# Aliases go here
alias nano='nvim'
alias 'nvim /'='sudo nvim '
alias ls='eza --icons'
alias grep='grep --color=auto'
alias yay='yay --color=always'
alias pacman='pacman --color=auto'
alias hyprpaper='hyprpaper -c ~/.config/hypr/hyprpaper/hyprpaper.conf'
alias clear='clear && printf "\033c"'
alias hyprconfig='nvim ~/.config/hypr/hyprland.conf'
alias pip='pip --require-virtualenv'
alias cat='bat'
alias u='yay -Suy --noconfirm'
alias speedtest='speedtest --secure --bytes'
alias codex='codex --dangerously-bypass-approvals-and-sandbox'
# OpenCode
function opencode-resume() {
    local session_id session_list
    session_list=$(opencode session list 2>/dev/null |
        sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g; s/\r//g' |
        grep '^ses_' |
        awk '{
            id=$1
            rest=substr($0, length($1)+1)
            gsub(/^[[:space:]]+/, "", rest)
            gsub(/[[:space:]]+[0-9]+:[0-9]+ [AP]M.*$/, "", rest)
            print id "\t" rest
          }')
    session_id=$(echo "$session_list" | fzf --delimiter='\t' --with-nth=2 --no-preview | cut -f1)
    [ -n "$session_id" ] && opencode -s "$session_id"
}

# OpenFOAM
alias ofoam='source /opt/OpenFOAM/OpenFOAM-13/etc/bashrc'
alias of='source /opt/OpenFOAM/OpenFOAM-13/etc/bashrc'

# YouTube in mpv - tiled, no decorations, pure video
alias yt='mpv --no-border'
alias subway_surfer='mpv --no-border --start=971 "https://youtu.be/vTfD20dbxho"'

# Proton VPN
alias pvpn='protonvpn'
compdef pvpn=protonvpn 2>/dev/null

# Claude Code - skip permission prompts
alias cc='claude --dangerously-skip-permissions'
