# Aliases only.
# Shell functions live in ~/.zshrc.d/functions.sh; topic modules (hue, tmux,
# uxtrace, completions) keep their own file.

# --- editors ---
alias v='nvim'
alias nano='nvim'
alias sv='sudo -E nvim'
alias hyprconfig='cd ~/.config/hypr/'

# --- listing & files ---
alias ls='eza --icons=auto'
alias ll='ls -l' # zsh re-expands `ls`, so ll/la inherit whatever ls is set to
alias la='ls -la'
alias tree='nt'
alias cat='bat'
alias tv='tidy-viewer'
alias grep='grep --color=auto'

# --- packages ---
alias yay='yay --color=always'
# No `u` alias: ~/bin/u is the real thing (same yay -Syu fast path, but it
# diagnoses failures and can hand them to Claude instead of dying).

# --- python ---
alias pip='pip --require-virtualenv'

# --- tools ---
alias cc='claude --dangerously-skip-permissions'
alias oc='opencode --auto'
alias codex='codex --dangerously-bypass-approvals-and-sandbox'
alias agy='agy --dangerously-skip-permissions'
alias antigravity='agy --dangerously-skip-permissions'
alias clear='clear && printf "\033c"'
alias speedtest='speedtest --secure --bytes'
alias wakeword='~/.conda/envs/wakeword/bin/python ~/Projects/AI/wakeword/listen.py'

# --- video ---
alias yt='mpv --no-border'
alias subway_surfer='mpv --no-border --start=971 "https://youtu.be/vTfD20dbxho"'

# --- vpn ---
alias pvpn='protonvpn'
compdef pvpn=protonvpn 2>/dev/null
