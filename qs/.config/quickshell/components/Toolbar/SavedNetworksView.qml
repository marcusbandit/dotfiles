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
    property color colCard: "#24283b"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 16

    property var savedNetworks: []

    signal back()
    signal showQrCode(var network)
    signal toggleAutoconnect(var network)
    signal forgetNetwork(var network)
    signal showPassword(var network)
    signal showHidden()

    implicitHeight: savedColumn.implicitHeight

    Column {
        id: savedColumn
        width: parent.width
        spacing: 10

        // Header with back button and title
        Item {
            width: parent.width
            height: 40

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                Rectangle {
                    id: backBtn
                    width: 32
                    height: 32
                    radius: 8
                    color: backMa.containsMouse ? root.colHover : "transparent"
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
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            // Hidden network button on right
            Rectangle {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: hiddenRow.width + 16
                height: 32
                radius: 8
                color: hiddenBtnMa.containsMouse ? root.colHover : "transparent"
                border.width: 1
                border.color: root.colMuted

                Row {
                    id: hiddenRow
                    anchors.centerIn: parent
                    spacing: 6

                    Text {
                        text: "󰛵"
                        color: root.colMuted
                        font.family: root.fontFamily
                        font.pixelSize: 12
                    }

                    Text {
                        text: "Hidden"
                        color: root.colMuted
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                    }
                }

                MouseArea {
                    id: hiddenBtnMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.showHidden()
                }
            }
        }

        // Saved networks list with fade effect
        Item {
            width: parent.width
            height: Math.min(savedFlickable.contentHeight, 350)

            Flickable {
                id: savedFlickable
                anchors.fill: parent
                contentHeight: savedList.implicitHeight
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: savedList
                    width: parent.width
                    spacing: 6

                    Repeater {
                        model: root.savedNetworks

                        Rectangle {
                            id: savedItem
                            required property var modelData
                            required property int index

                            width: savedList.width
                            height: savedItemRow.height + 16
                            radius: 8
                            color: itemMa.containsMouse ? root.colHover : root.colCard

                            MouseArea {
                                id: itemMa
                                anchors.fill: parent
                                hoverEnabled: true
                            }

                            Row {
                                id: savedItemRow
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.margins: 10
                                spacing: 10

                                // WiFi icon
                                Text {
                                    text: "󰤨"
                                    color: root.colActive
                                    font.family: root.fontFamily
                                    font.pixelSize: 18
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                // Network name and status
                                Column {
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 2
                                    width: parent.width - 120

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
                                        text: savedItem.modelData.autoconnect ? "Auto-connect" : "Manual"
                                        color: savedItem.modelData.autoconnect ? root.colSuccess : root.colMuted
                                        font.family: root.fontFamily
                                        font.pixelSize: root.fontSize - 4
                                    }
                                }

                                // Share/QR button
                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 6
                                    color: qrMa.containsMouse ? root.colHover : Qt.darker(root.colCard, 1.2)
                                    border.width: 1
                                    border.color: root.colMuted
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰐲"
                                        color: root.colFg
                                        font.family: root.fontFamily
                                        font.pixelSize: 16
                                    }

                                    MouseArea {
                                        id: qrMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: root.showQrCode(savedItem.modelData)
                                    }
                                }

                                // More options button
                                Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 6
                                    color: moreMa.containsMouse ? root.colHover : "transparent"
                                    anchors.verticalCenter: parent.verticalCenter

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰇙"
                                        color: root.colMuted
                                        font.family: root.fontFamily
                                        font.pixelSize: 14
                                    }

                                    MouseArea {
                                        id: moreMa
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            optionsPopup.network = savedItem.modelData;
                                            optionsPopup.visible = !optionsPopup.visible;
                                        }
                                    }
                                }
                            }

                            // Inline options popup
                            Rectangle {
                                id: optionsPopup
                                property var network: null
                                visible: false
                                anchors.top: parent.bottom
                                anchors.topMargin: 4
                                anchors.right: parent.right
                                anchors.rightMargin: 10
                                width: 140
                                height: optionsColumn.height + 12
                                radius: 8
                                color: root.colBg
                                border.width: 1
                                border.color: root.colHover
                                z: 100

                                Column {
                                    id: optionsColumn
                                    anchors.centerIn: parent
                                    width: parent.width - 12
                                    spacing: 4

                                    // Toggle autoconnect
                                    Rectangle {
                                        width: parent.width
                                        height: 32
                                        radius: 4
                                        color: autoMa.containsMouse ? root.colHover : "transparent"

                                        Row {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 8
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 8

                                            Text {
                                                text: optionsPopup.network && optionsPopup.network.autoconnect ? "󰒃" : "󰒄"
                                                color: root.colFg
                                                font.family: root.fontFamily
                                                font.pixelSize: 12
                                            }

                                            Text {
                                                text: optionsPopup.network && optionsPopup.network.autoconnect ? "Disable auto" : "Enable auto"
                                                color: root.colFg
                                                font.family: root.fontFamily
                                                font.pixelSize: root.fontSize - 3
                                            }
                                        }

                                        MouseArea {
                                            id: autoMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.toggleAutoconnect(optionsPopup.network);
                                                optionsPopup.visible = false;
                                            }
                                        }
                                    }

                                    // Show password
                                    Rectangle {
                                        width: parent.width
                                        height: 32
                                        radius: 4
                                        color: passMa.containsMouse ? root.colHover : "transparent"

                                        Row {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 8
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 8

                                            Text {
                                                text: "󰈉"
                                                color: root.colFg
                                                font.family: root.fontFamily
                                                font.pixelSize: 12
                                            }

                                            Text {
                                                text: "Show password"
                                                color: root.colFg
                                                font.family: root.fontFamily
                                                font.pixelSize: root.fontSize - 3
                                            }
                                        }

                                        MouseArea {
                                            id: passMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.showPassword(optionsPopup.network);
                                                optionsPopup.visible = false;
                                            }
                                        }
                                    }

                                    // Forget network
                                    Rectangle {
                                        width: parent.width
                                        height: 32
                                        radius: 4
                                        color: forgetMa.containsMouse ? Qt.rgba(root.colError.r, root.colError.g, root.colError.b, 0.2) : "transparent"

                                        Row {
                                            anchors.left: parent.left
                                            anchors.leftMargin: 8
                                            anchors.verticalCenter: parent.verticalCenter
                                            spacing: 8

                                            Text {
                                                text: "󰆴"
                                                color: root.colError
                                                font.family: root.fontFamily
                                                font.pixelSize: 12
                                            }

                                            Text {
                                                text: "Forget"
                                                color: root.colError
                                                font.family: root.fontFamily
                                                font.pixelSize: root.fontSize - 3
                                            }
                                        }

                                        MouseArea {
                                            id: forgetMa
                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                root.forgetNetwork(optionsPopup.network);
                                                optionsPopup.visible = false;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Bottom fade effect
            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 40
                visible: savedFlickable.contentHeight > savedFlickable.height &&
                         savedFlickable.contentY < savedFlickable.contentHeight - savedFlickable.height - 10

                gradient: Gradient {
                    GradientStop { position: 0.0; color: "transparent" }
                    GradientStop { position: 1.0; color: root.colBg }
                }

                // Scroll indicator arrow
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    text: "󰅀"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: 16

                    SequentialAnimation on y {
                        running: savedFlickable.contentHeight > savedFlickable.height
                        loops: Animation.Infinite
                        NumberAnimation { from: 0; to: 4; duration: 500; easing.type: Easing.InOutQuad }
                        NumberAnimation { from: 4; to: 0; duration: 500; easing.type: Easing.InOutQuad }
                    }
                }
            }
        }

        // Empty state
        Rectangle {
            width: parent.width
            height: 80
            radius: 10
            color: root.colCard
            visible: root.savedNetworks.length === 0

            Column {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "󰤭"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: 28
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "No saved networks"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }
}
