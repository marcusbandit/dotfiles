import QtQuick

// Bluetooth button (placeholder - no features yet)
Item {
    id: root

    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property bool isHovered: false

    width: 38
    height: 38

    Rectangle {
        anchors.fill: parent
        radius: 19
        color: root.isHovered ? root.colMuted : root.colBg

        Text {
            anchors.centerIn: parent
            text: "󰂯"
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
}
