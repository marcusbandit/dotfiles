import QtQuick
import Quickshell.Io

// Network status button with hover popup
Item {
    id: root

    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    // Network state
    property string connectionType: "none"  // "wifi", "wired", "none"
    property int signalStrength: 0          // 0-100 for wifi
    property string networkName: ""
    property string localIp: ""

    property bool isHovered: false

    // Icons based on state
    property string icon: {
        if (connectionType === "wired") return "󰈀";  // Ethernet icon
        if (connectionType === "none") return "󰤭";   // No connection
        // WiFi icons based on signal strength
        if (signalStrength > 75) return "󰤨";         // Strong
        if (signalStrength > 50) return "󰤥";         // Medium
        if (signalStrength > 25) return "󰤢";         // Weak
        return "󰤟";                                   // Very weak
    }

    width: 38
    height: 38

    // Main button
    Rectangle {
        id: button
        anchors.fill: parent
        radius: 19
        color: root.isHovered ? root.colMuted : root.colBg

        Text {
            anchors.centerIn: parent
            text: root.icon
            color: root.colFg
            font.family: root.fontFamily
            font.pixelSize: 18
        }
    }


    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onContainsMouseChanged: root.isHovered = containsMouse
    }

    // Query network status
    Process {
        id: networkProc
        command: ["sh", "-c", "nmcli -t -f TYPE,STATE,CONNECTION device | grep -E ':connected:' | head -1"]
        stdout: SplitParser {
            onRead: data => {
                var parts = data.trim().split(":");
                if (parts.length >= 3) {
                    var type = parts[0];
                    root.networkName = parts[2] || "";
                    if (type === "wifi") {
                        root.connectionType = "wifi";
                    } else if (type === "ethernet") {
                        root.connectionType = "wired";
                    }
                } else {
                    root.connectionType = "none";
                    root.networkName = "";
                }
            }
        }
    }

    // Query signal strength (wifi only)
    Process {
        id: signalProc
        command: ["sh", "-c", "nmcli -t -f IN-USE,SIGNAL dev wifi | grep '*' | cut -d: -f2"]
        stdout: SplitParser {
            onRead: data => {
                var sig = parseInt(data.trim());
                root.signalStrength = isNaN(sig) ? 0 : sig;
            }
        }
    }

    // Query local IP
    Process {
        id: ipProc
        command: ["sh", "-c", "ip -4 route get 1.1.1.1 2>/dev/null | grep -oP 'src \\K[^ ]+' | head -1"]
        stdout: SplitParser {
            onRead: data => {
                root.localIp = data.trim();
            }
        }
    }

    Timer {
        interval: 5000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            networkProc.running = true;
            signalProc.running = true;
            ipProc.running = true;
        }
    }
}
