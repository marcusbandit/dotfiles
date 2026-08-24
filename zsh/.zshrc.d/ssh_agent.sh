#!/usr/bin/env zsh
# Point SSH at gcr-ssh-agent (gnome-keyring's modern SSH agent, ships in gcr-4).
# Enabled via: systemctl --user enable --now gcr-ssh-agent.socket
# Socket is socket-activated, so the .service starts on first connection.

if [[ -S "${XDG_RUNTIME_DIR:-/run/user/$UID}/gcr/ssh" ]]; then
    export SSH_AUTH_SOCK="${XDG_RUNTIME_DIR:-/run/user/$UID}/gcr/ssh"
fi
