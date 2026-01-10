import QtQuick

// Main WiFi view with network list, IP display, and controls
Item {
    id: root
    implicitHeight: mainViewColumn.implicitHeight

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

    // Data
    property bool wifiEnabled: true
    property string localIp: "Not connected"
    property string connectedSsid: ""
    property var networks: []
    property bool scanning: false

    // Signals
    signal toggleWifi()
    signal refresh()
    signal networkClicked(var network)
    signal showSaved()
    signal showHidden()

    Column {
        id: mainViewColumn
        anchors.fill: parent
        spacing: 10

        // Header with WiFi toggle
        Item {
            width: parent.width
            height: 40

            Text {
                text: "WiFi"
                color: root.colFg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 2
                font.bold: true
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }

            // WiFi Toggle Switch
            Rectangle {
                id: wifiToggle
                anchors.right: refreshBtn.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 48
                height: 26
                radius: 13
                color: root.wifiEnabled ? root.colActive : root.colMuted

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                Rectangle {
                    id: toggleKnob
                    width: 22
                    height: 22
                    radius: 11
                    color: root.colFg
                    anchors.verticalCenter: parent.verticalCenter
                    x: root.wifiEnabled ? parent.width - width - 2 : 2

                    Behavior on x {
                        NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.toggleWifi()
                }
            }

            // Refresh button
            Rectangle {
                id: refreshBtn
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 32
                height: 32
                radius: 16
                color: refreshMa.containsMouse ? root.colHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰑐"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: 16
                    rotation: refreshRotation.running ? refreshRotation.angle : 0

                    NumberAnimation on rotation {
                        id: refreshRotation
                        property real angle: 0
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: root.scanning
                    }
                }

                MouseArea {
                    id: refreshMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.refresh()
                }
            }
        }

        // Connected Network & IP Display
        Rectangle {
            width: parent.width
            height: connectedColumn.height + 20
            radius: 10
            color: Qt.rgba(root.colActive.r, root.colActive.g, root.colActive.b, 0.15)
            visible: root.connectedSsid !== ""

            Column {
                id: connectedColumn
                anchors.centerIn: parent
                width: parent.width - 20
                spacing: 8

                // Connected network name
                Row {
                    spacing: 10
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text {
                        text: "󰤨"
                        color: root.colActive
                        font.family: root.fontFamily
                        font.pixelSize: 22
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: root.connectedSsid
                            color: root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            font.bold: true
                        }

                        Text {
                            text: "Connected"
                            color: root.colSuccess
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 4
                        }
                    }
                }

                // Local IP
                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                    color: Qt.rgba(root.colBg.r, root.colBg.g, root.colBg.b, 0.5)

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "󰩟"
                            color: root.colActive
                            font.family: root.fontFamily
                            font.pixelSize: 14
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.localIp
                            color: root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }

        // Not connected state
        Rectangle {
            width: parent.width
            height: 50
            radius: 10
            color: Qt.rgba(root.colMuted.r, root.colMuted.g, root.colMuted.b, 0.15)
            visible: root.connectedSsid === "" && root.wifiEnabled

            Row {
                anchors.centerIn: parent
                spacing: 10

                Text {
                    text: "󰤭"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: 20
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: "Not connected"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Separator
        Rectangle {
            width: parent.width
            height: 1
            color: root.colHover
        }

        // Available Networks header
        Item {
            width: parent.width
            height: 24

            Text {
                text: "Available Networks (" + root.networks.length + ")"
                color: root.colMuted
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 2
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // Network list - fills remaining space
        Flickable {
            width: parent.width
            height: Math.min(networkList.implicitHeight, 180)
            contentHeight: networkList.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: networkList.implicitHeight > height

            Column {
                id: networkList
                width: parent.width
                spacing: 4

                Repeater {
                    model: root.networks

                    NetworkListItem {
                        required property var modelData
                        required property int index

                        width: networkList.width
                        network: modelData
                        colBg: root.colBg
                        colFg: root.colFg
                        colMuted: root.colMuted
                        colActive: root.colActive
                        colHover: root.colHover
                        colSuccess: root.colSuccess
                        fontFamily: root.fontFamily
                        fontSize: root.fontSize

                        onClicked: root.networkClicked(modelData)
                    }
                }
            }
        }

        // Empty state
        Text {
            text: root.scanning ? "Scanning..." : (root.wifiEnabled ? "No networks found" : "WiFi is disabled")
            color: root.colMuted
            font.family: root.fontFamily
            font.pixelSize: root.fontSize - 1
            visible: root.networks.length === 0
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Separator
        Rectangle {
            width: parent.width
            height: 1
            color: root.colHover
        }

        // Bottom buttons
        Row {
            width: parent.width
            spacing: 8

            // Saved Networks button
            Rectangle {
                width: (parent.width - 8) / 2
                height: 38
                radius: 8
                color: savedMa.containsMouse ? root.colHover : "transparent"

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰒓"
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: 14
                    }

                    Text {
                        text: "Saved"
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 2
                    }
                }

                MouseArea {
                    id: savedMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showSaved()
                }
            }

            // Hidden Network button
            Rectangle {
                width: (parent.width - 8) / 2
                height: 38
                radius: 8
                color: hiddenMa.containsMouse ? root.colHover : "transparent"

                Row {
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰛵"
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: 14
                    }

                    Text {
                        text: "Hidden"
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 2
                    }
                }

                MouseArea {
                    id: hiddenMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showHidden()
                }
            }
        }
    }
}
