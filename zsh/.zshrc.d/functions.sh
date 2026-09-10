# Shell functions.
# Aliases live in ~/.zshrc.d/aliases.sh; topic modules (hue, tmux,
# uxtrace) keep their own file.

# fzf-pick an OpenCode session (by title, ids hidden) and resume it.
opencode-resume() {
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

# Toggle a wide left gap in Hyprland so a second person can see the screen.
# Optional arg = left gap in px (default 600). State in $XDG_STATE_HOME.
albert_here() {
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
