import QtQuick

// Clock component showing DD-MMM HH:MM:SS with clear time display
Item {
    id: root

    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property string dateStr: ""
    property string timeStr: ""
    property string secStr: ""
    property bool isHovered: false

    width: clockRow.width + 28
    height: 38

    Rectangle {
        anchors.fill: parent
        radius: 19
        color: root.colBg
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onContainsMouseChanged: root.isHovered = containsMouse
    }

    Row {
        id: clockRow
        anchors.centerIn: parent
        spacing: 8

        // Date: DD-MMM (secondary but readable)
        Text {
            text: root.dateStr
            color: Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.6)
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            anchors.baseline: timeText.baseline
        }

        // Time: HH:MM:SS (primary display)
        Text {
            id: timeText
            text: root.timeStr + ":" + root.secStr
            color: root.colFg
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            font.bold: true
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun",
                          "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
            var day = now.getDate().toString().padStart(2, '0');
            var month = months[now.getMonth()];
            var hours = now.getHours().toString().padStart(2, '0');
            var mins = now.getMinutes().toString().padStart(2, '0');
            var secs = now.getSeconds().toString().padStart(2, '0');

            root.dateStr = day + "-" + month;
            root.timeStr = hours + ":" + mins;
            root.secStr = secs;
        }
    }
}
