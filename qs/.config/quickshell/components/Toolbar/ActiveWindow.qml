import QtQuick
import Quickshell.Io

// Active window title pill
Item {
    id: root

    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property string windowTitle: ""
    property int maxWidth: 250

    width: Math.min(titleText.implicitWidth + 28, maxWidth)
    height: 38
    visible: windowTitle !== ""

    Rectangle {
        anchors.fill: parent
        radius: 19
        color: root.colBg
    }

    Text {
        id: titleText
        anchors.centerIn: parent
        width: Math.min(implicitWidth, root.maxWidth - 28)
        text: root.windowTitle
        color: root.colFg
        font.family: root.fontFamily
        font.pixelSize: root.fontSize
        elide: Text.ElideRight
    }

    // Query active window title
    Process {
        id: titleProc
        command: ["sh", "-c", "hyprctl activewindow -j | jq -r '.title // empty'"]
        stdout: SplitParser {
            onRead: data => {
                root.windowTitle = data.trim();
            }
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            titleProc.running = true;
        }
    }
}
