import QtQuick

// Saved networks management view
Item {
    id: root

    // Theme
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property color colActive: "#7aa2f7"
    property color colHover: "#414868"
    property color colError: "#f7768e"
    property color colSuccess: "#9ece6a"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 16

    property var savedNetworks: []

    signal back()
    signal showQrCode(var network)
    signal toggleAutoconnect(var network)
    signal forgetNetwork(var network)
    signal showPassword(var network)

    implicitHeight: savedColumn.implicitHeight

    Column {
        id: savedColumn
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
                text: "Saved Networks"
                color: root.colFg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 2
                font.bold: true
                anchors.centerIn: parent
            }
        }

        // Saved networks list
        Flickable {
            width: parent.width
            height: Math.min(savedList.implicitHeight, 350)
            contentHeight: savedList.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            Column {
                id: savedList
                width: parent.width
                spacing: 8

                Repeater {
                    model: root.savedNetworks

                    Rectangle {
                        id: savedItem
                        required property var modelData
                        required property int index

                        width: savedList.width
                        height: savedItemColumn.height
                        radius: 10
                        color: Qt.rgba(root.colHover.r, root.colHover.g, root.colHover.b, 0.5)

                        Column {
                            id: savedItemColumn
                            width: parent.width
                            padding: 12
                            spacing: 10

                            // Network name and autoconnect status
                            Row {
                                width: parent.width - 24
                                spacing: 10

                                Text {
                                    text: "󰤨"
                                    color: root.colActive
                                    font.family: root.fontFamily
                                    font.pixelSize: 18
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    width: parent.width - 100

                                    Text {
                                        text: savedItem.modelData.name
                                        color: root.colFg
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 1
                                        font.bold: true
                                        elide: Text.ElideRight
                                        width: parent.width
                                    }

                                    Text {
                                        text: savedItem.modelData.autoconnect ? "Auto-connect enabled" : "Auto-connect disabled"
                                        color: savedItem.modelData.autoconnect ? root.colSuccess : root.colMuted
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 4
                                    }
                                }
                            }

                            // Password display (if revealed)
                            Rectangle {
                                visible: savedItem.modelData.revealedPassword !== null
                                width: parent.width - 24
                                height: visible ? 36 : 0
                                radius: 6
                                color: root.colBg

                                Row {
                                    anchors.fill: parent
                                    anchors.margins: 8
                                    spacing: 8

                                    Text {
                                        text: "󰌆"
                                        color: root.colMuted
                                        font.family: root.fontFamily
                                        font.pixelSize: 14
                                        anchors.verticalCenter: parent.verticalCenter
                                    }

                                    Text {
                                        text: savedItem.modelData.revealedPassword || ""
                                        color: root.colFg
                                        font.family: "monospace"
                                        font.pixelSize: root.fontSize - 2
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                Behavior on height {
                                    NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                                }
                            }

                            // Action buttons
                            Row {
                                width: parent.width - 24
                                spacing: 6

                                // Show Password
                                Rectangle {
                                    width: (parent.width - 18) / 4
                                    height: 32
                                    radius: 6
                                    color: showPassMa.containsMouse ? root.colHover : "transparent"
                                    border.width: 1
                                    border.color: root.colMuted

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰈉"
                                        color: root.colFg
                                        font.family: root.fontFamily
                                        font.pixelSize: 14
                                    }

                                    MouseArea {
                                        id: showPassMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.showPassword(savedItem.modelData)
                                    }
                                }

                                // QR Code
                                Rectangle {
                                    width: (parent.width - 18) / 4
                                    height: 32
                                    radius: 6
                                    color: qrMa.containsMouse ? root.colHover : "transparent"
                                    border.width: 1
                                    border.color: root.colMuted

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰐲"
                                        color: root.colFg
                                        font.family: root.fontFamily
                                        font.pixelSize: 14
                                    }

                                    MouseArea {
                                        id: qrMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.showQrCode(savedItem.modelData)
                                    }
                                }

                                // Toggle autoconnect
                                Rectangle {
                                    width: (parent.width - 18) / 4
                                    height: 32
                                    radius: 6
                                    color: autoMa.containsMouse ? root.colHover : "transparent"
                                    border.width: 1
                                    border.color: savedItem.modelData.autoconnect ? root.colSuccess : root.colMuted

                                    Text {
                                        anchors.centerIn: parent
                                        text: savedItem.modelData.autoconnect ? "󰒃" : "󰒄"
                                        color: savedItem.modelData.autoconnect ? root.colSuccess : root.colMuted
                                        font.family: root.fontFamily
                                        font.pixelSize: 14
                                    }

                                    MouseArea {
                                        id: autoMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.toggleAutoconnect(savedItem.modelData)
                                    }
                                }

                                // Forget
                                Rectangle {
                                    width: (parent.width - 18) / 4
                                    height: 32
                                    radius: 6
                                    color: forgetMa.containsMouse ? Qt.rgba(root.colError.r, root.colError.g, root.colError.b, 0.2) : "transparent"
                                    border.width: 1
                                    border.color: root.colError

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰆴"
                                        color: root.colError
                                        font.family: root.fontFamily
                                        font.pixelSize: 14
                                    }

                                    MouseArea {
                                        id: forgetMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.forgetNetwork(savedItem.modelData)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        // Empty state
        Text {
            text: "No saved networks"
            color: root.colMuted
            font.family: root.fontFamily
            font.pixelSize: root.fontSize - 1
            visible: root.savedNetworks.length === 0
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }
}
