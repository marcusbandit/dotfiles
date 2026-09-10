# Hue bridge controls. Token and bridge IP live in the 600-perms api-keys env file.
[[ -r $HOME/.config/marcusbandit-api-keys.env ]] &&
    source "$HOME/.config/marcusbandit-api-keys.env"

#— get full light info —#
hue_get() {
    curl -s -X GET \
        "http://${HUE_BRIDGE}/api/${HUE_TOKEN}/lights/$1" |
        jq
}

#— get only the .state object —#
hue_state() {
    hue_get $1 | jq '.state'
}

#— set one or more state fields —#
hue_set() {
    local ID=$1
    shift
    curl -s -X PUT \
        -H "Content-Type: application/json" \
        -d "${*}" \
        "http://${HUE_BRIDGE}/api/${HUE_TOKEN}/lights/${ID}/state" |
        jq
}

#— toggle on/off —#
hue_toggle() {
    local ID=$1
    local CUR NEW
    CUR=$(hue_state $ID | jq -r '.on') # yields true|false (no quotes)
    if [[ $CUR == true ]]; then
        NEW=false
    else
        NEW=true
    fi
    hue_set $ID "{\"on\":${NEW}}"
}
