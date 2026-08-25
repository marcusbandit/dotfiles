# zsh-autosuggestions: don't limit suggestions to shell history.
# Default strategy is (history), which is why a command has to be typed once
# before it ever gets suggested. Fall back to the completion system when
# history has no match, so unseen commands/flags/paths still get suggested.
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Don't try to suggest for very long buffers (keeps the completion fallback snappy).
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=40
