#!/bin/bash
# Kill leftover processes for Discord and Discord Canary
if ! pgrep -f "DiscordCanary" >/dev/null && ! pgrep -f "discord" >/dev/null; then
    pkill -9 -f DiscordCanary
    pkill -9 -f discord
fi

