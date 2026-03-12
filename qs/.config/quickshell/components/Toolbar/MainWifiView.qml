import QtQuick
import Quickshell.Io

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
    property color colCard: "#24283b"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 16

    // Data
    property bool wifiEnabled: true
    property string localIp: "Not connected"
    property string connectedSsid: ""
    property var networks: []
    property bool scanning: false

    // Share panel state - controls whether card shows QR or normal view
    property bool showingShare: false
    property string qrImagePath: ""
    property bool qrGenerating: false
    property string revealedPassword: ""

    // Signals
    signal toggleWifi()
    signal refresh()
    signal networkClicked(var network)
    signal showSaved()

    Column {
        id: mainViewColumn
        width: parent.width
        spacing: 10

        // Header with WiFi toggle
        Item {
            width: parent.width
            height: 40

            Row {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6

                Text {
                    text: "WiFi"
                    color: root.colFg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize + 2
                    font.bold: true
                    anchors.verticalCenter: parent.verticalCenter
                }

                // "More" button (three dots) - opens saved networks
                Rectangle {
                    width: 24
                    height: 24
                    radius: 4
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
                        onClicked: root.showSaved()
                    }
                }
            }

            // WiFi Toggle Switch
            Rectangle {
                id: wifiToggle
                anchors.right: refreshBtn.left
                anchors.rightMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width: 44
                height: 24
                radius: 12
                color: root.wifiEnabled ? root.colActive : root.colMuted

                Behavior on color {
                    ColorAnimation { duration: 200 }
                }

                Rectangle {
                    width: 20
                    height: 20
                    radius: 10
                    color: "#ffffff"
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
                width: 28
                height: 28
                radius: 14
                color: refreshMa.containsMouse ? root.colHover : "transparent"

                Text {
                    anchors.centerIn: parent
                    text: "󰑐"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: 14

                    RotationAnimation on rotation {
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

        // Connected Network Card - expands in-place for share view
        Item {
            id: connectedCardWrapper
            width: parent.width
            height: root.showingShare ? expandedHeight : collapsedHeight
            visible: root.connectedSsid !== ""
            clip: true

            property real collapsedHeight: 102
            property real expandedHeight: 320 + (root.revealedPassword !== "" ? 46 : 0)

            Behavior on height {
                NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
            }

            // Background - no animation, always full size
            Rectangle {
                id: connectedCardBg
                width: parent.width
                height: parent.expandedHeight
                radius: 10
                color: root.colCard
            }

            Column {
                id: cardContent
                width: parent.width - 20
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 10
                spacing: 10

                // Top row: Network info OR Back button (depending on state)
                Item {
                    width: parent.width
                    height: 50

                    // Normal state: WiFi icon + Network info
                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 10
                        opacity: root.showingShare ? 0 : 1
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }

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

                    // Share state: Back button + Network name
                    Row {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8
                        opacity: root.showingShare ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }

                        Rectangle {
                            width: 28
                            height: 28
                            radius: 6
                            color: backMa.containsMouse ? root.colHover : "transparent"
                            anchors.verticalCenter: parent.verticalCenter

                            Text {
                                anchors.centerIn: parent
                                text: "󰁍"
                                color: root.colFg
                                font.family: root.fontFamily
                                font.pixelSize: 14
                            }

                            MouseArea {
                                id: backMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.showingShare = false
                            }
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
                                text: "Share"
                                color: root.colMuted
                                font.family: root.fontFamily
                                font.pixelSize: root.fontSize - 4
                            }
                        }
                    }

                    // Share button (only in normal state)
                    Rectangle {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        width: 42
                        height: 42
                        radius: 8
                        color: shareMa.containsMouse ? root.colHover : Qt.darker(root.colCard, 1.2)
                        border.width: 1
                        border.color: root.colMuted
                        opacity: root.showingShare ? 0 : 1
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰐲"
                            color: root.colFg
                            font.family: root.fontFamily
                            font.pixelSize: 18
                        }

                        MouseArea {
                            id: shareMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.showingShare = true;
                                root.generateQrCode();
                            }
                        }
                    }
                }

                // Local IP row (only in normal state)
                Rectangle {
                    width: parent.width
                    height: 32
                    radius: 6
                    color: Qt.darker(root.colCard, 1.3)
                    opacity: root.showingShare ? 0 : 1
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Text {
                            text: "LOCAL IP"
                            color: root.colMuted
                            font.family: root.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: root.localIp
                            color: root.colActive
                            font.family: root.fontFamily
                            font.pixelSize: root.fontSize - 1
                            font.bold: true
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                // QR Code section (only in share state)
                Column {
                    width: parent.width
                    spacing: 12
                    opacity: root.showingShare ? 1 : 0
                    visible: opacity > 0

                    Behavior on opacity {
                        NumberAnimation { duration: 150 }
                    }

                    // QR Code display
                    Rectangle {
                        width: 160
                        height: 160
                        radius: 8
                        color: "#ffffff"
                        anchors.horizontalCenter: parent.horizontalCenter

                        Image {
                            anchors.fill: parent
                            anchors.margins: 8
                            source: root.qrImagePath ? "file://" + root.qrImagePath : ""
                            fillMode: Image.PreserveAspectFit
                            visible: root.qrImagePath !== "" && !root.qrGenerating
                        }

                        // Loading state
                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            color: root.colBg
                            font.family: root.fontFamily
                            font.pixelSize: 32
                            visible: root.qrGenerating

                            RotationAnimation on rotation {
                                from: 0
                                to: 360
                                duration: 1000
                                loops: Animation.Infinite
                                running: root.qrGenerating
                            }
                        }
                    }

                    // Password display
                    Rectangle {
                        width: parent.width
                        height: 36
                        radius: 6
                        color: Qt.darker(root.colCard, 1.3)
                        visible: root.revealedPassword !== ""

                        Row {
                            anchors.centerIn: parent
                            spacing: 8

                            Text {
                                text: "󰌆"
                                color: root.colMuted
                                font.family: root.fontFamily
                                font.pixelSize: 14
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: root.revealedPassword
                                color: root.colFg
                                font.family: "monospace"
                                font.pixelSize: root.fontSize - 2
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                    }

                    // Scan to connect text
                    Text {
                        text: "Scan to connect"
                        color: root.colMuted
                        font.family: root.fontFamily
                        font.pixelSize: root.fontSize - 3
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }
            }
        }

        // Not connected state
        Rectangle {
            width: parent.width
            height: 50
            radius: 10
            color: root.colCard
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

        // Available Networks section
        Item {
            width: parent.width
            height: availableNetworksColumn.height
            visible: root.wifiEnabled

            Column {
                id: availableNetworksColumn
                width: parent.width
                spacing: 8

                // Header
                Text {
                    text: "Available (" + root.networks.length + ")"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 3
                    font.bold: true
                }

                // Network list with fade effect
                Item {
                    width: parent.width
                    height: Math.min(networkFlickable.contentHeight, 200)

                    Flickable {
                        id: networkFlickable
                        anchors.fill: parent
                        contentHeight: networkList.implicitHeight
                        clip: true
                        boundsBehavior: Flickable.StopAtBounds
                        interactive: contentHeight > height

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

                    // Bottom fade effect
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 50
                        visible: networkFlickable.contentHeight > networkFlickable.height &&
                                 networkFlickable.contentY < networkFlickable.contentHeight - networkFlickable.height - 5

                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "transparent" }
                            GradientStop { position: 1.0; color: Qt.rgba(0, 0, 0, 0.9) }
                        }

                        // Scroll indicator arrow
                        Text {
                            id: scrollArrow
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 8
                            text: "󰅀"
                            color: root.colMuted
                            font.family: root.fontFamily
                            font.pixelSize: 16

                            SequentialAnimation on anchors.bottomMargin {
                                running: networkFlickable.contentHeight > networkFlickable.height
                                loops: Animation.Infinite
                                NumberAnimation { to: 12; duration: 400; easing.type: Easing.InOutQuad }
                                NumberAnimation { to: 8; duration: 400; easing.type: Easing.InOutQuad }
                            }
                        }
                    }
                }

                // Empty state
                Text {
                    text: root.scanning ? "Scanning..." : "No networks found"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 1
                    visible: root.networks.length === 0
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // WiFi disabled state
        Rectangle {
            width: parent.width
            height: 80
            radius: 10
            color: root.colCard
            visible: !root.wifiEnabled

            Column {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "󰤮"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: 32
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: "WiFi is disabled"
                    color: root.colMuted
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }
    }

    // QR Code generation
    function generateQrCode() {
        root.qrGenerating = true;
        root.qrImagePath = "";
        root.revealedPassword = "";
        getPasswordProc.running = true;
    }

    Process {
        id: getPasswordProc
        command: ["nmcli", "-s", "-g", "802-11-wireless-security.psk", "connection", "show", root.connectedSsid]
        property string outputBuffer: ""
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { getPasswordProc.outputBuffer += data; }
        }
        onRunningChanged: {
            if (running) {
                outputBuffer = "";
            } else {
                var password = outputBuffer.trim();
                root.revealedPassword = password;

                var wifiString = password ?
                    "WIFI:T:WPA;S:" + root.connectedSsid + ";P:" + password + ";;" :
                    "WIFI:T:nopass;S:" + root.connectedSsid + ";;";

                var timestamp = Date.now();
                qrGenProc.command = ["sh", "-c", "qrencode -t PNG -o /tmp/wifi_qr_" + timestamp + ".png -s 10 '" + wifiString + "' && echo /tmp/wifi_qr_" + timestamp + ".png"];
                qrGenProc.running = true;
            }
        }
    }

    Process {
        id: qrGenProc
        property string outputBuffer: ""
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { qrGenProc.outputBuffer += data; }
        }
        onRunningChanged: {
            if (running) {
                outputBuffer = "";
            } else {
                root.qrImagePath = outputBuffer.trim();
                root.qrGenerating = false;
            }
        }
    }

    // Reset share view when SSID changes
    onConnectedSsidChanged: {
        root.showingShare = false;
        root.qrImagePath = "";
        root.revealedPassword = "";
    }
}
