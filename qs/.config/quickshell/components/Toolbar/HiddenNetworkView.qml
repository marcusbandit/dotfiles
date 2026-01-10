import QtQuick

// Hidden network connection view
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

    property bool showPassword: false

    signal connect(string ssid, string password)
    signal cancel()

    implicitHeight: hiddenColumn.implicitHeight

    Column {
        id: hiddenColumn
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
                    onClicked: root.cancel()
                }
            }

            Text {
                text: "Hidden Network"
                color: root.colFg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 2
                font.bold: true
                anchors.centerIn: parent
            }
        }

        // Info text
        Text {
            text: "Enter the network name (SSID) and password for the hidden network."
            color: root.colMuted
            font.family: root.fontFamily
            font.pixelSize: root.fontSize - 2
            width: parent.width
            wrapMode: Text.WordWrap
        }

        // SSID input
        Column {
            width: parent.width
            spacing: 4

            Text {
                text: "Network Name (SSID)"
                color: root.colMuted
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 3
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: 8
                color: root.colHover
                border.width: ssidInput.activeFocus ? 2 : 0
                border.color: root.colActive

                TextInput {
                    id: ssidInput
                    anchors.fill: parent
                    anchors.margins: 4
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    verticalAlignment: TextInput.AlignVCenter
                    leftPadding: 12
                    clip: true
                    selectByMouse: true

                    Text {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        verticalAlignment: Text.AlignVCenter
                        text: "Enter SSID"
                        color: root.colMuted
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                        visible: ssidInput.text === "" && !ssidInput.activeFocus
                    }

                    Keys.onTabPressed: passwordInput.forceActiveFocus()
                }
            }
        }

        // Password input
        Column {
            width: parent.width
            spacing: 4

            Text {
                text: "Password (leave empty for open networks)"
                color: root.colMuted
                font.family: root.fontFamily
                font.pixelSize: root.fontSize - 3
            }

            Rectangle {
                width: parent.width
                height: 44
                radius: 8
                color: root.colHover
                border.width: passwordInput.activeFocus ? 2 : 0
                border.color: root.colActive

                Row {
                    anchors.fill: parent
                    anchors.margins: 4

                    TextInput {
                        id: passwordInput
                        width: parent.width - toggleVisBtn.width - 8
                        height: parent.height
                        color: root.colFg
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize
                        echoMode: root.showPassword ? TextInput.Normal : TextInput.Password
                        verticalAlignment: TextInput.AlignVCenter
                        leftPadding: 12
                        clip: true
                        selectByMouse: true

                        Text {
                            anchors.fill: parent
                            anchors.leftMargin: 12
                            verticalAlignment: Text.AlignVCenter
                            text: "Password"
                            color: root.colMuted
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize
                            visible: passwordInput.text === "" && !passwordInput.activeFocus
                        }

                        Keys.onReturnPressed: {
                            if (ssidInput.text.length > 0) {
                                root.connect(ssidInput.text, passwordInput.text);
                            }
                        }

                        Keys.onEscapePressed: root.cancel()
                    }

                    // Toggle visibility button
                    Rectangle {
                        id: toggleVisBtn
                        width: 36
                        height: parent.height
                        radius: 6
                        color: toggleVisMa.containsMouse ? Qt.rgba(root.colFg.r, root.colFg.g, root.colFg.b, 0.1) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: root.showPassword ? "󰈈" : "󰈉"
                            color: root.colMuted
                            font.family: root.fontFamily
                            font.pixelSize: 16
                        }

                        MouseArea {
                            id: toggleVisMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.showPassword = !root.showPassword
                        }
                    }
                }
            }
        }

        // Buttons
        Row {
            width: parent.width
            spacing: 8

            Rectangle {
                width: (parent.width - 8) / 2
                height: 40
                radius: 8
                color: cancelMa.containsMouse ? root.colHover : "transparent"
                border.width: 1
                border.color: root.colMuted

                Text {
                    anchors.centerIn: parent
                    text: "Cancel"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                }

                MouseArea {
                    id: cancelMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.cancel()
                }
            }

            Rectangle {
                width: (parent.width - 8) / 2
                height: 40
                radius: 8
                color: connectMa.containsMouse ? Qt.darker(root.colActive, 1.1) : root.colActive
                opacity: ssidInput.text.length > 0 ? 1 : 0.5

                Text {
                    anchors.centerIn: parent
                    text: "Connect"
                    color: root.colBg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    font.bold: true
                }

                MouseArea {
                    id: connectMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: ssidInput.text.length > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: {
                        if (ssidInput.text.length > 0) {
                            root.connect(ssidInput.text, passwordInput.text);
                        }
                    }
                }
            }
        }
    }

    // Focus SSID input when view becomes visible
    onVisibleChanged: {
        if (visible) {
            ssidInput.text = "";
            passwordInput.text = "";
            ssidInput.forceActiveFocus();
        }
    }
}
