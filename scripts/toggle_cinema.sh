#!/bin/bash
STATE_FILE="/tmp/cinema_mode_active.txt"
DISPLAYS=(1 2)

set_defaults() {
    local disp="$1"
    ddcutil setvcp 0x0C 6500 --display "$disp"
    ddcutil setvcp 10 100 --display "$disp"
    ddcutil setvcp 12 100 --display "$disp"
    ddcutil setvcp 6C 128 --display "$disp"
    ddcutil setvcp 6E 128 --display "$disp"
    ddcutil setvcp 70 128 --display "$disp"
}

set_cinema() {
    local disp="$1"
    ddcutil setvcp 10 0 --display "$disp"
    ddcutil setvcp 12 0 --display "$disp"
    ddcutil setvcp 6C 0 --display "$disp"
    ddcutil setvcp 6E 0 --display "$disp"
    ddcutil setvcp 70 0 --display "$disp"
}

if [ -f "$STATE_FILE" ]; then
    echo "Restoring default settings for displays ${DISPLAYS[@]}..."
    for disp in "${DISPLAYS[@]}"; do
        set_defaults "$disp"
    done
    rm -f "$STATE_FILE"
    echo "Cinema mode deactivated."
else
    echo "Activating cinema mode for displays ${DISPLAYS[@]}..."
    for disp in "${DISPLAYS[@]}"; do
        set_cinema "$disp"
    done
    touch "$STATE_FILE"
    echo "Cinema mode activated."
fi
