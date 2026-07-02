#compdef wifi

# Tab completion for the `wifi` helper (~/bin/wifi).

_wifi() {
    local -a subcmds
    subcmds=(
        'pick:Interactive picker (scan, pick, connect)'
        'connect:Connect to a network by name'
        'hidden:Connect to a hidden (non-broadcast) network'
        'enterprise:Set up 802.1X / enterprise (eduroam, DTUsecure)'
        'portal:Open the captive-portal login page'
        'status:Show current network, signal, IP, internet state'
        'list:List nearby networks'
        'saved:List saved networks'
        'forget:Delete a saved network'
        'qr:Show a QR code so a phone can join'
        'on:Turn the WiFi radio on'
        'off:Turn the WiFi radio off'
        'rescan:Force a fresh scan'
        'help:Show help'
    )

    # SSIDs currently in range (deduped).
    _wifi_nearby() {
        local -a nets
        nets=( ${(f)"$(nmcli -t -e no -f SSID device wifi list 2>/dev/null | awk 'NF && !seen[$0]++')"} )
        _describe -t networks 'nearby network' nets
    }
    # SSIDs already saved as NetworkManager profiles.
    _wifi_saved() {
        local -a nets
        nets=( ${(f)"$(nmcli -t -e no -f TYPE,NAME connection show 2>/dev/null | awk -F: '$1=="802-11-wireless"{sub(/^[^:]*:/,""); print}')"} )
        _describe -t saved 'saved network' nets
    }

    if (( CURRENT == 2 )); then
        _describe -t commands 'wifi command' subcmds
        _wifi_nearby
        return
    fi

    case "${words[2]}" in
        connect|hidden)      _wifi_nearby ;;
        enterprise|ent|eap)  _wifi_nearby ;;
        forget|rm|delete|qr|share) _wifi_saved ;;
        *) ;;
    esac
}

if [[ $zsh_eval_context[-1] == loadautofunc ]]; then
    _wifi "$@"
else
    compdef _wifi wifi
fi
