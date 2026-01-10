import QtQuick
import Quickshell.Io

// QR Code view for sharing WiFi credentials
Item {
    id: root

    // Theme
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property color colActive: "#7aa2f7"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 16

    property string networkName: ""
    property string qrImagePath: ""
    property bool generating: false

    signal back()

    implicitHeight: qrColumn.implicitHeight

    Column {
        id: qrColumn
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
                text: "QR Code"
                color: root.colFg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 2
                font.bold: true
                anchors.centerIn: parent
            }
        }

        // Network name
        Text {
            text: root.networkName
            color: root.colActive
            font.family: root.fontFamily
            font.pixelSize: root.fontSize
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // QR Code display
        Rectangle {
            width: 200
            height: 200
            radius: 10
            color: "#ffffff"
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: qrImage
                anchors.fill: parent
                anchors.margins: 10
                source: root.qrImagePath ? "file://" + root.qrImagePath : ""
                fillMode: Image.PreserveAspectFit
                visible: root.qrImagePath !== "" && !root.generating
            }

            // Loading state
            Column {
                anchors.centerIn: parent
                spacing: 8
                visible: root.generating || root.qrImagePath === ""

                Text {
                    text: root.generating ? "󰑐" : "󰐲"
                    color: root.colBg
                    font.family: root.fontFamily
                    font.pixelSize: 40
                    anchors.horizontalCenter: parent.horizontalCenter

                    RotationAnimation on rotation {
                        from: 0
                        to: 360
                        duration: 1000
                        loops: Animation.Infinite
                        running: root.generating
                    }
                }

                Text {
                    text: root.generating ? "Generating..." : "No QR code"
                    color: root.colBg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize - 2
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }
        }

        // Instructions
        Text {
            text: "Scan to connect"
            color: root.colMuted
            font.family: root.fontFamily
            font.pixelSize: root.fontSize - 2
            anchors.horizontalCenter: parent.horizontalCenter
        }
    }

    // Generate QR code when network name changes
    onNetworkNameChanged: {
        if (networkName && visible) {
            generateQrCode();
        }
    }

    onVisibleChanged: {
        if (visible && networkName) {
            generateQrCode();
        }
    }

    function generateQrCode() {
        root.generating = true;
        root.qrImagePath = "";
        // First get the password, then generate QR
        getPasswordProc.running = true;
    }

    // Get password for QR code generation
    Process {
        id: getPasswordProc
        command: ["nmcli", "-s", "-g", "802-11-wireless-security.psk", "connection", "show", root.networkName]
        stdout: SplitParser {
            onRead: data => {
                var password = data.trim();
                // Generate QR code with WiFi credentials
                // Format: WIFI:T:WPA;S:<SSID>;P:<password>;;
                var wifiString = "WIFI:T:WPA;S:" + root.networkName + ";P:" + password + ";;";
                qrGenProc.command = ["sh", "-c", "qrencode -t PNG -o /tmp/wifi_qr_" + Date.now() + ".png -s 10 '" + wifiString + "' && echo /tmp/wifi_qr_" + Date.now() + ".png"];
                qrGenProc.running = true;
            }
        }
        onRunningChanged: {
            if (!running && !qrGenProc.running) {
                // If password retrieval fails, try without password (open network)
                var wifiString = "WIFI:T:nopass;S:" + root.networkName + ";;";
                qrGenProc.command = ["sh", "-c", "f=/tmp/wifi_qr_$(date +%s).png && qrencode -t PNG -o $f -s 10 '" + wifiString + "' && echo $f"];
                qrGenProc.running = true;
            }
        }
    }

    // Generate QR code image
    Process {
        id: qrGenProc
        stdout: SplitParser {
            onRead: data => {
                root.qrImagePath = data.trim();
                root.generating = false;
            }
        }
        onRunningChanged: {
            if (!running && root.qrImagePath === "") {
                root.generating = false;
            }
        }
    }
}
