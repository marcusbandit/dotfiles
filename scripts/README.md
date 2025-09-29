# Scripts Package

This package contains user scripts managed by GNU Stow.

## Structure

```
scripts/
├── .local/
│   └── bin/
│       ├── com.joaomgcd.taskerpermissions-0.2.0.AppImage
│       ├── discord_kill.sh
│       ├── ollama-tui
│       ├── rofi-dark
│       ├── swww-random
│       ├── toggle-waybar
│       ├── type-clipboard
│       └── waybar-cursor-toggle
└── README.md
```

## Scripts Description

- **waybar-cursor-toggle**: Monitors cursor position and automatically shows/hides Waybar
- **toggle-waybar**: Manual toggle script for Waybar visibility (bound to SUPER+Z)
- **discord_kill.sh**: Script to kill Discord processes
- **rofi-dark**: Dark theme configuration for Rofi
- **swww-random**: Random wallpaper setter using swww
- **type-clipboard**: Clipboard typing utility
- **ollama-tui**: Terminal UI for Ollama
- **com.joaomgcd.taskerpermissions-0.2.0.AppImage**: Tasker permissions app

## Management

- **Stow**: `stow scripts` - Creates symlinks in ~/.local/bin/
- **Unstow**: `stow -D scripts` - Removes symlinks
- **Restow**: `stow -R scripts` - Recreates symlinks

## Notes

- `cursor-agent` and `modrinth` are not managed by this package as they are external symlinks
- All scripts maintain their original functionality after stowing