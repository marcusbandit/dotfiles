_usb_prompt_check() {
    if [[ "$PWD" == /run/media/$USER/* ]]; then
        export USB_PROMPT_ICON="󰚥"
    elif [[ "$PWD" == /mnt/* || "$PWD" == /media/* ]]; then
        export USB_PROMPT_ICON="󰋊"
    else
        export USB_PROMPT_ICON=""
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _usb_prompt_check
