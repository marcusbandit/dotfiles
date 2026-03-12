import QtQuick

// Individual network item in the list with expandable details
Item {
    id: root

    property var network: null
    property bool expanded: false

    // Theme
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property color colActive: "#7aa2f7"
    property color colHover: "#414868"
    property color colSuccess: "#9ece6a"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 16

    signal clicked()

    height: contentColumn.height
    implicitHeight: contentColumn.height

    Rectangle {
        anchors.fill: parent
        radius: 8
        color: itemMa.containsMouse ? root.colHover : (root.network && root.network.connected ? Qt.lighter(root.colBg, 1.15) : "transparent")

        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }

    Column {
        id: contentColumn
        width: parent.width
        spacing: 0

        // Main row
        Item {
            width: parent.width
            height: 48

            // Signal icon
            Text {
                id: signalIcon
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    if (!root.network) return "󰤯";
                    var sig = root.network.signal || 0;
                    if (sig > 75) return "󰤨";
                    if (sig > 50) return "󰤥";
                    if (sig > 25) return "󰤢";
                    return "󰤟";
                }
                color: root.network && root.network.connected ? root.colActive : root.colMuted
                font.family: root.fontFamily
                font.pixelSize: 18
            }

            // Network info
            Column {
                anchors.left: signalIcon.right
                anchors.leftMargin: 10
                anchors.right: rightInfo.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 2

                Text {
                    text: root.network ? root.network.ssid : ""
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    font.bold: root.network && root.network.connected
                    elide: Text.ElideRight
                    width: parent.width
                }

                Row {
                    spacing: 6
                    visible: root.network && root.network.connected

                    Text {
                        text: "Connected"
                        color: root.colSuccess
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 4
                    }
                }
            }

            // Right side info
            Row {
                id: rightInfo
                anchors.right: expandIcon.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                // Security badge
                Rectangle {
                    visible: root.network && root.network.security !== "Open"
                    width: securityText.width + 10
                    height: 20
                    radius: 4
                    color: Qt.rgba(root.colActive.r, root.colActive.g, root.colActive.b, 0.2)
                    border.width: 1
                    border.color: Qt.rgba(root.colActive.r, root.colActive.g, root.colActive.b, 0.4)
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        id: securityText
                        anchors.centerIn: parent
                        text: root.network ? (root.network.security.indexOf("WPA3") !== -1 ? "WPA3" : (root.network.security.indexOf("WPA2") !== -1 ? "WPA2" : "WPA")) : ""
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: 10
                    }
                }

                // Signal percentage
                Text {
                    text: root.network ? root.network.signal + "%" : ""
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 3
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Expand icon
            Text {
                id: expandIcon
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: root.expanded ? "󰅀" : "󰅂"
                color: root.colMuted
                font.family: root.fontFamily
                font.pixelSize: 14
                rotation: root.expanded ? 0 : 0

                Behavior on text {
                    SequentialAnimation {
                        NumberAnimation { target: expandIcon; property: "opacity"; to: 0; duration: 100 }
                        PropertyAction { target: expandIcon; property: "text" }
                        NumberAnimation { target: expandIcon; property: "opacity"; to: 1; duration: 100 }
                    }
                }
            }

            MouseArea {
                id: itemMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.network && root.network.connected) {
                        root.expanded = !root.expanded;
                    } else {
                        root.clicked();
                    }
                }
            }
        }

        // Expanded details
        Item {
            width: parent.width
            height: root.expanded ? expandedContent.height : 0
            clip: true
            opacity: root.expanded ? 1 : 0

            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            Behavior on opacity {
                NumberAnimation { duration: 200 }
            }

            Column {
                id: expandedContent
                width: parent.width
                leftPadding: 38
                rightPadding: 10
                bottomPadding: 10
                spacing: 6

                // Separator
                Rectangle {
                    width: parent.width - 48
                    height: 1
                    color: root.colHover
                }

                // BSSID
                Row {
                    spacing: 8
                    Text {
                        text: "BSSID:"
                        color: root.colMuted
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                        width: 70
                    }
                    Text {
                        text: root.network ? root.network.bssid : ""
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                    }
                }

                // Frequency
                Row {
                    spacing: 8
                    Text {
                        text: "Frequency:"
                        color: root.colMuted
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                        width: 70
                    }
                    Text {
                        text: root.network ? root.network.frequency : ""
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                    }
                }

                // Rate
                Row {
                    spacing: 8
                    Text {
                        text: "Rate:"
                        color: root.colMuted
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                        width: 70
                    }
                    Text {
                        text: root.network ? root.network.rate : ""
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                    }
                }

                // Security
                Row {
                    spacing: 8
                    Text {
                        text: "Security:"
                        color: root.colMuted
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                        width: 70
                    }
                    Text {
                        text: root.network ? root.network.security : ""
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                    }
                }

                // Connect/Disconnect button for expanded
                Rectangle {
                    width: parent.width - 48
                    height: 32
                    radius: 6
                    color: connectBtnMa.containsMouse ? Qt.lighter(root.colHover, 1.2) : root.colHover
                    visible: root.network && root.network.connected

                    Text {
                        anchors.centerIn: parent
                        text: "View Details"
                        color: root.colActive
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 2
                    }

                    MouseArea {
                        id: connectBtnMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.clicked()
                    }
                }
            }
        }
    }
}
