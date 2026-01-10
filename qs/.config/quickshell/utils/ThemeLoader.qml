import QtQuick
import Quickshell.Io

// Utility component for loading theme colors from environment
Item {
    id: root
    
    property color themeBg: "#1a1b26"
    property color themeFg: "#a9b1d6"
    property color themeMuted: "#414868"
    property color themeAccent: "#7aa2f7"
    property color themeUrgent: "#f7768e"
    property color themeWarning: "#e0af68"
    property color themeBorder: "#565f89"
    property color themeWindowEdge: "#00000000"
    
    // Load theme colors from environment
    Process {
        id: colorProc
        command: ["bash", "-c", "source ~/.zshrc.d/colors.sh && jq -n -c '{bg: env.THEME_BG, fg: env.THEME_FG, muted: env.THEME_MUTED, accent: env.THEME_ACCENT, urgent: env.THEME_URGENT, warning: env.THEME_WARNING, border: env.THEME_BORDER, windowEdge: env.THEME_WINDOW_EDGE}'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let colors = JSON.parse(data.trim());
                if (colors.bg) root.themeBg = colors.bg;
                if (colors.fg) root.themeFg = colors.fg;
                if (colors.muted) root.themeMuted = colors.muted;
                if (colors.accent) root.themeAccent = colors.accent;
                if (colors.urgent) root.themeUrgent = colors.urgent;
                if (colors.warning) root.themeWarning = colors.warning;
                if (colors.border) root.themeBorder = colors.border;
                if (colors.windowEdge) root.themeWindowEdge = colors.windowEdge;
            }
        }
    }
}
