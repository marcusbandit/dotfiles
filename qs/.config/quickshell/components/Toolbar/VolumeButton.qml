import QtQuick
import Quickshell.Io

// Volume button that shows volume state and launches pavucontrol
Item {
    id: root

    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property int volume: 0
    property bool isMuted: false

    property bool isHovered: false

    // Icon based on volume state
    property string icon: {
        if (isMuted || volume === 0) return "󰝟";  // Muted
        if (volume > 66) return "󰕾";              // High
        if (volume > 33) return "󰖀";              // Medium
        return "󰕿";                                // Low
    }

    width: 38
    height: 38

    Rectangle {
        anchors.fill: parent
        radius: 19
        color: root.isHovered ? root.colMuted : root.colBg

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.isMuted ? root.colMuted : root.colFg
            font.family: root.fontFamily
            font.pixelSize: 18
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.isHovered = containsMouse
        onClicked: {
            launchProc.running = true;
        }
    }

    // Launch pavucontrol
    Process {
        id: launchProc
        command: ["pavucontrol"]
    }

    // Query volume using wpctl (PipeWire)
    Process {
        id: volumeProc
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || pactl get-sink-volume @DEFAULT_SINK@ 2>/dev/null | grep -oP '\\d+%' | head -1 | tr -d '%'"]
        stdout: SplitParser {
            onRead: data => {
                // wpctl output: "Volume: 0.50" or "Volume: 0.50 [MUTED]"
                // pactl output: just a number
                var text = data.trim();
                if (text.indexOf("MUTED") !== -1) {
                    root.isMuted = true;
                } else {
                    root.isMuted = false;
                }

                // Extract volume
                var match = text.match(/[\d.]+/);
                if (match) {
                    var val = parseFloat(match[0]);
                    // wpctl returns 0.0-1.0, pactl returns 0-100
                    if (val <= 1.5) {
                        root.volume = Math.round(val * 100);
                    } else {
                        root.volume = Math.round(val);
                    }
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            volumeProc.running = true;
        }
    }
}
