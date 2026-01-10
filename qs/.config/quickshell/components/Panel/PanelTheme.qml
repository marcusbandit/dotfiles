import QtQuick
import "../../utils" as Utils

// Theme loading and color management for the panel
Item {
    id: root
    
    property color colPanelBg: "#00000000"
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#414868"
    property color colCyan: "#0db9d7"
    property color colBlue: "#7aa2f7"
    property color colYellow: "#e0af68"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 16
    
    // Load theme colors from environment
    Utils.ThemeLoader {
        id: themeLoader
        onThemeBgChanged: root.colBg = themeBg
        onThemeFgChanged: root.colFg = themeFg
        onThemeMutedChanged: root.colMuted = themeMuted
        onThemeAccentChanged: root.colBlue = themeAccent
        onThemeWarningChanged: root.colYellow = themeWarning
        onThemeWindowEdgeChanged: root.colPanelBg = themeWindowEdge
    }
}
