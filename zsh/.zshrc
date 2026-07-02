# ~/.zshrc
# Aliases, exports, PATH, functions and completions live in ~/.zshrc.d/*.sh
# This file is only for Oh My Zsh, the prompt, and core shell init.
# --- Oh My Zsh ---
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""                 # empty: the prompt is drawn by oh-my-posh (below)
plugins=(
    git
    history
    zsh-syntax-highlighting
    zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh

# --- Prompt (oh-my-posh) ---
eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/bandit_theme.json)"

# --- fzf integration (Ctrl+T files, Ctrl+R history, Alt+C dirs) ---
# The fd/ripgrep commands and appearance options are set in ~/.zshrc.d/exports.sh
if [[ -f ~/.fzf.zsh ]]; then
    source ~/.fzf.zsh
else
    [[ -r /usr/share/fzf/key-bindings.zsh ]] && source /usr/share/fzf/key-bindings.zsh
    [[ -r /usr/share/fzf/completion.zsh ]] && source /usr/share/fzf/completion.zsh
fi

# --- Modular config: ~/.zshrc.d/*.sh (aliases, exports, path, functions, completions) ---
if [[ -d ~/.zshrc.d ]]; then
    for f in ~/.zshrc.d/*.sh; do
        [[ -r "$f" ]] && source "$f"
    done
    unset f
fi

# --- conda / miniforge (opt-in: export CONDA_MANUAL=1 before launching to enable) ---
if [[ -n "$CONDA_MANUAL" ]]; then
    __conda_setup="$('/home/bandit/miniforge/bin/conda' 'shell.zsh' 'hook' 2>/dev/null)"
    if [[ $? -eq 0 ]]; then
        eval "$__conda_setup"
    else
        # Hook failed: at least put conda on PATH without activating base.
        export PATH="/home/bandit/miniforge/bin:$PATH"
    fi
    unset __conda_setup
fi

# --- zoxide (smarter cd) ---
eval "$(zoxide init --cmd cd zsh)"

# --- Auto-start tmux (interactive local shells only; not in SSH/VSCode/nested tmux) ---
if [[ -o interactive ]] && [[ -t 1 ]] && [[ -z "$VSCODE_INJECTION" ]] && [[ -z "$SSH_TTY" ]] && [[ -z "$TMUX" ]] && [[ -z "$DISABLE_AUTO_TMUX" ]]; then
    /home/bandit/.local/bin/tmux-wrapper.sh
fi
