# Aliases go here
alias v='nvim'
alias nano='nvim'
alias 'nvim /'='sudo nvim '
alias ls='eza --icons'
alias tree='nt'
alias ll='eza --icons -l'
alias la='eza --icons -la'
alias grep='grep --color=auto'
alias yay='yay --color=always'
alias pacman='pacman --color=auto'
alias hyprpaper='hyprpaper -c ~/.config/hypr/hyprpaper/hyprpaper.conf'
alias clear='clear && printf "\033c"'
alias hyprconfig='nvim ~/.config/hypr/hyprland.conf'
alias pip='pip --require-virtualenv'
alias cat='bat'
alias zed='zeditor'
# libjpeg-turbo held back: 3.2.0-2 dropped the plain 'libjpeg' provides colmap
# depends on; Arch hasn't rebuilt colmap yet. Remove --ignore once it's fixed upstream.
alias u='yay -Suy --noconfirm --ignore libjpeg-turbo'
alias speedtest='speedtest --secure --bytes'
alias wakeword='~/.conda/envs/wakeword/bin/python ~/Projects/wakeword/listen.py'
alias tv='tidy-viewer'
alias cc='claude --dangerously-skip-permissions'

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

function albert_here() {
  local state_dir state_file
  local albert_gaps default_gaps default_left_gap left_gap

  state_dir="${XDG_STATE_HOME:-$HOME/.local/state}"
  state_file="$state_dir/albert_here_mode"
  default_gaps="10, 10, 10, 10"
  default_left_gap=600
  left_gap="${1:-$default_left_gap}"

  if [[ ! "$left_gap" =~ ^[0-9]+$ ]]; then
    echo "Usage: albert_here [left_gap]"
    return 1
  fi

  albert_gaps="10, 10, 10, $left_gap"

  mkdir -p "$state_dir"

  if [[ -f "$state_file" && "$(cat "$state_file")" == "$albert_gaps" ]]; then
    hyprctl keyword general:gaps_out "$default_gaps" >/dev/null
    rm -f "$state_file"
    echo "albert_here: off ($default_gaps)"
  else
    hyprctl keyword general:gaps_out "$albert_gaps" >/dev/null
    printf '%s\n' "$albert_gaps" >"$state_file"
    echo "albert_here: on ($albert_gaps)"
  fi
}
