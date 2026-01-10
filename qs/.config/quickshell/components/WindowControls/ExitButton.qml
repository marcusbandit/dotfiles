import QtQuick

// Exit button component for window controls
Rectangle {
    id: root
    
    property int windowControlsHeight: 40
    property color themeBg: "#1a1b26"
    property color themeFg: "#a9b1d6"
    property color themeAccent: "#7aa2f7"
    property color themeBorder: "#565f89"
    property string exitIcon: ""
    
    signal clicked()
    
    height: root.windowControlsHeight
    width: root.windowControlsHeight
    color: root.themeBg
    border.color: root.themeBorder
    border.width: 1
    radius: height / 2
    
    Text {
        anchors.centerIn: parent
        text: root.exitIcon
        // Subtle hover feedback - just icon color change
        color: exitMa.containsMouse ? root.themeAccent : root.themeFg
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 20
        font.bold: true
    }
    
    MouseArea {
        id: exitMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
