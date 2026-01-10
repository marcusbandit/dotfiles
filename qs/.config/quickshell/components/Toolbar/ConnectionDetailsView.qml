import QtQuick

// Connection details view for currently connected network
Item {
    id: root

    // Theme
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property color colActive: "#7aa2f7"
    property color colHover: "#414868"
    property color colError: "#f7768e"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 16

    property var network: null
    property string localIp: ""

    signal back()
    signal disconnect()

    implicitHeight: detailsColumn.implicitHeight

    Column {
        id: detailsColumn
        width: parent.width
        spacing: 12

        // Header with back button
        Item {
            width: parent.width
            height: 32

            Rectangle {
                id: backBtn
                width: 32
                height: 32
                radius: 16
                color: backMa.containsMouse ? root.colHover : "transparent"
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    anchors.centerIn: parent
                    text: "󰁍"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: 16
                }

                MouseArea {
                    id: backMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.back()
                }
            }

            Text {
                text: "Connection Details"
                color: root.colFg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 2
                font.bold: true
                anchors.centerIn: parent
            }
        }

        // Network name and status
        Rectangle {
            width: parent.width
            height: 60
            radius: 10
            color: Qt.rgba(root.colActive.r, root.colActive.g, root.colActive.b, 0.15)

            Row {
                anchors.centerIn: parent
                spacing: 12

                Text {
                    text: "󰤨"
                    color: root.colActive
                    font.family: root.fontFamily
                    font.pixelSize: 24
                    anchors.verticalCenter: parent.verticalCenter
                }

                Column {
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2

                    Text {
                        text: root.network ? root.network.ssid : ""
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                        font.bold: true
                    }

                    Text {
                        text: "Connected"
                        color: root.colActive
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                    }
                }
            }
        }

        // Details list
        Rectangle {
            width: parent.width
            radius: 10
            color: Qt.rgba(root.colHover.r, root.colHover.g, root.colHover.b, 0.5)
            height: detailsList.height + 20

            Column {
                id: detailsList
                width: parent.width - 20
                anchors.centerIn: parent
                spacing: 8

                // Local IP
                DetailRow {
                    label: "IP Address"
                    value: root.localIp
                    colMuted: root.colMuted
                    colFg: root.colFg
                    colActive: root.colActive
                    fontFamily: root.fontFamily
                    fontSize: root.fontSize
                    highlight: true
                }

                Rectangle { width: parent.width; height: 1; color: root.colHover }

                // Signal
                DetailRow {
                    label: "Signal"
                    value: root.network ? root.network.signal + "%" : ""
                    colMuted: root.colMuted
                    colFg: root.colFg
                    colActive: root.colActive
                    fontFamily: root.fontFamily
                    fontSize: root.fontSize
                }

                Rectangle { width: parent.width; height: 1; color: root.colHover }

                // Security
                DetailRow {
                    label: "Security"
                    value: root.network ? root.network.security : ""
                    colMuted: root.colMuted
                    colFg: root.colFg
                    colActive: root.colActive
                    fontFamily: root.fontFamily
                    fontSize: root.fontSize
                }

                Rectangle { width: parent.width; height: 1; color: root.colHover }

                // BSSID
                DetailRow {
                    label: "BSSID"
                    value: root.network ? root.network.bssid : ""
                    colMuted: root.colMuted
                    colFg: root.colFg
                    colActive: root.colActive
                    fontFamily: root.fontFamily
                    fontSize: root.fontSize
                }

                Rectangle { width: parent.width; height: 1; color: root.colHover }

                // Frequency
                DetailRow {
                    label: "Frequency"
                    value: root.network ? root.network.frequency : ""
                    colMuted: root.colMuted
                    colFg: root.colFg
                    colActive: root.colActive
                    fontFamily: root.fontFamily
                    fontSize: root.fontSize
                }

                Rectangle { width: parent.width; height: 1; color: root.colHover }

                // Rate
                DetailRow {
                    label: "Link Speed"
                    value: root.network ? root.network.rate : ""
                    colMuted: root.colMuted
                    colFg: root.colFg
                    colActive: root.colActive
                    fontFamily: root.fontFamily
                    fontSize: root.fontSize
                }
            }
        }

        // Disconnect button
        Rectangle {
            width: parent.width
            height: 44
            radius: 8
            color: disconnectMa.containsMouse ? Qt.rgba(root.colError.r, root.colError.g, root.colError.b, 0.3) : Qt.rgba(root.colError.r, root.colError.g, root.colError.b, 0.15)
            border.width: 1
            border.color: root.colError

            Row {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "󰅗"
                    color: root.colError
                    font.family: root.fontFamily
                    font.pixelSize: 16
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Disconnect"
                    color: root.colError
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: disconnectMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.disconnect()
            }
        }
    }

    // Detail row component
    component DetailRow: Item {
        property string label: ""
        property string value: ""
        property color colMuted
        property color colFg
        property color colActive
        property string fontFamily
        property int fontSize
        property bool highlight: false

        width: parent.width
        height: 28

        Text {
            text: label
            color: colMuted
            font.family: fontFamily
            font.pixelSize: fontSize - 2
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: value
            color: highlight ? colActive : colFg
            font.family: fontFamily
            font.pixelSize: fontSize - 2
            font.bold: highlight
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
