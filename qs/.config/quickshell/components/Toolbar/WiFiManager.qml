import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

// WiFi Manager popup with full network management
// Uses LayerShell window on Top layer (behind panel) with slide-in animation
Scope {
    id: root

    // Required: screen reference from parent panel
    required property var panelScreen
    // Required: X position for the popup
    required property real xPosition
    // Required: panel height to position below
    required property real panelHeight
    // Corner radius (gaps + decoration rounding from Hyprland)
    property int cornerRadius: 20

    // Theme properties
    property color colPopupBg: "#000000"  // Pure black popup background
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property color colActive: "#7aa2f7"
    property color colHover: "#414868"
    property color colError: "#f7768e"
    property color colSuccess: "#9ece6a"
    property color colCard: "#24283b"     // Card background color
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 16

    // Network data
    property var networks: []
    property var savedNetworks: []
    property string connectedSsid: ""
    property string localIp: "Not connected"
    property bool wifiEnabled: true
    property bool scanning: false

    // View state: "main", "password", "saved", "qrcode", "hidden", "details"
    property string currentView: "main"
    property string previousView: "main"

    // Data for sub-views
    property var selectedNetwork: null
    property string passwordInput: ""
    property bool showPassword: false

    // Hover state for parent to track
    property bool isHovered: popupWindow.hovered

    // Visibility control
    property bool visible: false
    property bool isClosing: false  // True during slide-out animation
    property bool windowVisible: visible || isClosing  // Keep window visible during close animation

    // Signal to request closing the popup
    signal requestClose()

    // Animation speed for exponential smoothing
    property real animSpeed: 10.0

    // Slide animation properties - starts above panel, floats down
    property real slideOffset: -80  // Start just above visible area
    property real targetSlideOffset: 0
    property real smoothSlideOffset: -80

    // Content animation properties - start at full opacity
    property real expandProgress: 1
    property real contentOpacity: 1

    // Layer property - Top layer (value 2) is below Overlay (value 3)
    // This puts the popup behind the panel
    property int popupLayer: 2  // Default to Top layer

    Component.onCompleted: {
        try {
            if (typeof WlrLayershell !== 'undefined' && WlrLayershell.Layer) {
                root.popupLayer = WlrLayershell.Layer.Top;
            }
        } catch(e) {
            // Keep default value
        }
    }

    // Animation timer using exponential smoothing - only for slide position
    Timer {
        id: slideAnimTimer
        interval: 16  // ~60fps
        running: root.windowVisible
        repeat: true
        onTriggered: {
            let dt = interval / 1000.0;
            let factor = 1 - Math.exp(-root.animSpeed * dt);
            root.smoothSlideOffset += (root.targetSlideOffset - root.smoothSlideOffset) * factor;

            // Check if close animation is done (reached target within threshold)
            if (root.isClosing && Math.abs(root.smoothSlideOffset - root.targetSlideOffset) < 1) {
                root.isClosing = false;
            }
        }
    }

    onVisibleChanged: {
        if (visible) {
            // Cancel any closing animation
            isClosing = false;
            // Reset slide position - start above
            smoothSlideOffset = -80;
            targetSlideOffset = 0;

            // Load data
            scanning = true;
            scanProc.running = true;
            ipProc.running = true;
            wifiStatusProc.running = true;
            savedNetworksProc.running = true;
        } else {
            // Start close animation - slide back up by full height + panel height
            isClosing = true;
            targetSlideOffset = -(mainContainer.height + panelHeight + 20);
            currentView = "main";
        }
    }

    // The actual popup window - on Top layer (behind panel which is on Overlay)
    PanelWindow {
        id: popupWindow
        screen: root.panelScreen

        // Layer below the panel (Top is below Overlay)
        WlrLayershell.layer: root.popupLayer

        // Enable keyboard focus so password input can receive key events
        focusable: true
        WlrLayershell.keyboardFocus: WlrLayershell.KeyboardFocus.OnDemand

        // Use layer shell margins to position the window
        WlrLayershell.namespace: "wifi-popup"
        anchors.top: true
        anchors.left: true

        // Layer shell margins position the window - slide animation controls position
        // When not visible (and not closing), push far off-screen; otherwise use slide offset
        WlrLayershell.margins.top: Math.round(root.windowVisible ? root.smoothSlideOffset : -2000)
        WlrLayershell.margins.left: Math.round(root.xPosition - 180 - root.cornerRadius)

        // Size - include corner elements
        implicitWidth: 360 + root.cornerRadius * 2
        implicitHeight: mainContainer.height

        color: "transparent"

        // Always visible to avoid Wayland/compositor fade animations
        visible: true

        // Track hover state
        property bool hovered: hoverHandler.hovered

        HoverHandler {
            id: hoverHandler
        }

        // Escape key to close
        Shortcut {
            sequence: "Escape"
            enabled: popupWindow.visible
            onActivated: root.requestClose()
        }

        // Use mask to only receive input on the actual content area
        mask: Region {
            item: maskItem
        }

        // Mask item that includes main container and corner elements
        Item {
            id: maskItem
            x: 0
            y: 0
            width: mainContainer.width + root.cornerRadius * 2
            height: mainContainer.height + root.cornerRadius
        }

        // Left inner corner - creates inverted corner effect
        InnerRoundCorner {
            id: leftCorner
            x: 0
            y: 0
            cornerType: 2  // topRight (inverted, so shows as inner corner on left)
            radius: root.cornerRadius
            color: root.colPopupBg
        }

        // Right inner corner
        InnerRoundCorner {
            id: rightCorner
            x: root.cornerRadius + mainContainer.width
            y: 0
            cornerType: 1  // topLeft (inverted, so shows as inner corner on right)
            radius: root.cornerRadius
            color: root.colPopupBg
        }

        // Main container - slides in from above, black bg, flat top corners
        Item {
            id: mainContainer

            // Position within the window - offset by corner radius
            x: root.cornerRadius
            y: 0

            width: 360
            height: {
                // Get height from the currently visible view
                if (root.currentView === "main") return mainView.implicitHeight + 24;
                if (root.currentView === "password") return passwordView.implicitHeight + 24;
                if (root.currentView === "saved") return savedView.implicitHeight + 24;
                if (root.currentView === "qrcode") return qrView.implicitHeight + 24;
                if (root.currentView === "hidden") return hiddenView.implicitHeight + 24;
                if (root.currentView === "details") return detailsView.implicitHeight + 24;
                return 400;
            }
            clip: true

            Behavior on height {
                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
            }

            // Background - pure black with bottom corners rounded
            Rectangle {
                id: bgRect
                anchors.fill: parent
                color: root.colPopupBg
                radius: root.cornerRadius

                // Cover the top rounded corners with a flat rectangle
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: root.cornerRadius
                    color: root.colPopupBg
                }
            }

            // Content area with view switching
            Item {
                id: contentLoader
                anchors.fill: parent
                anchors.margins: 12

            // === MAIN VIEW ===
            MainWifiView {
                id: mainView
                visible: root.currentView === "main"
                opacity: visible ? 1 : 0

                width: parent.width
                height: parent.height

                Behavior on opacity {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }

                // Properties passed down
                colBg: root.colBg
                colFg: root.colFg
                colMuted: root.colMuted
                colActive: root.colActive
                colHover: root.colHover
                colError: root.colError
                colSuccess: root.colSuccess
                colCard: root.colCard
                fontFamily: root.fontFamily
                fontSize: root.fontSize

                wifiEnabled: root.wifiEnabled
                localIp: root.localIp
                connectedSsid: root.connectedSsid
                networks: root.networks
                scanning: root.scanning

                onToggleWifi: root.toggleWifi()
                onRefresh: root.rescan()
                onNetworkClicked: function(network) {
                    root.selectedNetwork = network;
                    if (network.connected) {
                        root.currentView = "details";
                    } else if (network.security !== "Open" && network.security !== "--") {
                        // Check if we have saved credentials
                        root.checkSavedAndConnect(network);
                    } else {
                        root.connectToNetwork(network.ssid, "");
                    }
                }
                onShowSaved: root.currentView = "saved"
            }

            // === PASSWORD INPUT VIEW ===
            PasswordInputView {
                id: passwordView
                visible: root.currentView === "password"
                opacity: visible ? 1 : 0
                width: parent.width
                height: parent.height

                Behavior on opacity {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }

                colBg: root.colBg
                colFg: root.colFg
                colMuted: root.colMuted
                colActive: root.colActive
                colHover: root.colHover
                colError: root.colError
                fontFamily: root.fontFamily
                fontSize: root.fontSize

                networkName: root.selectedNetwork ? root.selectedNetwork.ssid : ""

                onConnect: function(password) {
                    root.connectToNetwork(root.selectedNetwork.ssid, password);
                    root.currentView = "main";
                }
                onCancel: root.currentView = "main"
            }

            // === SAVED NETWORKS VIEW ===
            SavedNetworksView {
                id: savedView
                visible: root.currentView === "saved"
                opacity: visible ? 1 : 0
                width: parent.width
                height: parent.height

                Behavior on opacity {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }

                colBg: root.colBg
                colFg: root.colFg
                colMuted: root.colMuted
                colActive: root.colActive
                colHover: root.colHover
                colError: root.colError
                colSuccess: root.colSuccess
                colCard: root.colCard
                fontFamily: root.fontFamily
                fontSize: root.fontSize

                savedNetworks: root.savedNetworks

                onBack: root.currentView = "main"
                onShowQrCode: function(network) {
                    root.selectedNetwork = network;
                    root.currentView = "qrcode";
                }
                onToggleAutoconnect: function(network) {
                    root.toggleAutoconnect(network);
                }
                onForgetNetwork: function(network) {
                    root.forgetNetwork(network);
                }
                onShowPassword: function(network) {
                    root.revealPassword(network);
                }
                onShowHidden: root.currentView = "hidden"
            }

            // === QR CODE VIEW ===
            QrCodeView {
                id: qrView
                visible: root.currentView === "qrcode"
                opacity: visible ? 1 : 0
                width: parent.width
                height: parent.height

                Behavior on opacity {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }

                colBg: root.colBg
                colFg: root.colFg
                colMuted: root.colMuted
                colActive: root.colActive
                colHover: root.colHover
                colCard: root.colCard
                fontFamily: root.fontFamily
                fontSize: root.fontSize

                networkName: root.selectedNetwork ? root.selectedNetwork.ssid || root.selectedNetwork.name : ""

                onBack: root.currentView = "saved"
            }

            // === HIDDEN NETWORK VIEW ===
            HiddenNetworkView {
                id: hiddenView
                visible: root.currentView === "hidden"
                opacity: visible ? 1 : 0
                width: parent.width
                height: parent.height

                Behavior on opacity {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }

                colBg: root.colBg
                colFg: root.colFg
                colMuted: root.colMuted
                colActive: root.colActive
                colHover: root.colHover
                colError: root.colError
                fontFamily: root.fontFamily
                fontSize: root.fontSize

                onConnect: function(ssid, password) {
                    root.connectToHiddenNetwork(ssid, password);
                    root.currentView = "main";
                }
                onCancel: root.currentView = "main"
            }

            // === CONNECTION DETAILS VIEW ===
            ConnectionDetailsView {
                id: detailsView
                visible: root.currentView === "details"
                opacity: visible ? 1 : 0
                width: parent.width
                height: parent.height

                Behavior on opacity {
                    NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                }

                colBg: root.colBg
                colFg: root.colFg
                colMuted: root.colMuted
                colActive: root.colActive
                colHover: root.colHover
                colError: root.colError
                fontFamily: root.fontFamily
                fontSize: root.fontSize

                network: root.selectedNetwork
                localIp: root.localIp

                onBack: root.currentView = "main"
                onDisconnect: {
                    root.disconnectNetwork();
                    root.currentView = "main";
                }
            }
        }
        }  // Close mainContainer Rectangle
    }  // Close PanelWindow

    // === NETWORK MANAGER FUNCTIONS ===

    function toggleWifi() {
        wifiToggleProc.running = true;
    }

    function rescan() {
        if (!scanning) {
            scanning = true;
            rescanProc.running = true;
        }
    }

    function connectToNetwork(ssid, password) {
        if (password) {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password];
        } else {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid];
        }
        connectProc.running = true;
    }

    function connectToHiddenNetwork(ssid, password) {
        if (password) {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "password", password, "hidden", "yes"];
        } else {
            connectProc.command = ["nmcli", "device", "wifi", "connect", ssid, "hidden", "yes"];
        }
        connectProc.running = true;
    }

    function checkSavedAndConnect(network) {
        // Check if network is in saved networks
        checkSavedProc.command = ["nmcli", "-t", "-f", "NAME", "connection", "show"];
        checkSavedProc.network = network;
        checkSavedProc.running = true;
    }

    function disconnectNetwork() {
        disconnectProc.running = true;
    }

    function toggleAutoconnect(network) {
        var newState = network.autoconnect ? "no" : "yes";
        autoconnectProc.command = ["nmcli", "connection", "modify", network.name, "connection.autoconnect", newState];
        autoconnectProc.running = true;
    }

    function forgetNetwork(network) {
        forgetProc.command = ["nmcli", "connection", "delete", network.name];
        forgetProc.running = true;
    }

    function revealPassword(network) {
        revealPassProc.command = ["nmcli", "-s", "-g", "802-11-wireless-security.psk", "connection", "show", network.name];
        revealPassProc.network = network;
        revealPassProc.running = true;
    }

    // === PROCESSES ===

    // Toggle WiFi
    Process {
        id: wifiToggleProc
        command: root.wifiEnabled ? ["nmcli", "radio", "wifi", "off"] : ["nmcli", "radio", "wifi", "on"]
        onRunningChanged: {
            if (!running) {
                wifiStatusProc.running = true;
            }
        }
    }

    // Check WiFi status
    Process {
        id: wifiStatusProc
        property string outputBuffer: ""
        command: ["nmcli", "radio", "wifi"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { wifiStatusProc.outputBuffer += data; }
        }
        onRunningChanged: {
            if (running) { outputBuffer = ""; }
            else { root.wifiEnabled = outputBuffer.trim() === "enabled"; }
        }
    }

    // Scan networks
    Process {
        id: scanProc
        property string outputBuffer: ""
        command: ["nmcli", "-t", "-f", "SSID,SIGNAL,SECURITY,IN-USE,BSSID,FREQ,RATE", "device", "wifi", "list"]
        stdout: SplitParser {
            splitMarker: ""  // Receive all data as one chunk
            onRead: data => {
                scanProc.outputBuffer += data;
            }
        }
        onRunningChanged: {
            if (running) {
                outputBuffer = "";
            } else {
                // Process all the data when process finishes
                var lines = outputBuffer.trim().split("\n");
                var networkMap = {};
                var foundConnected = false;

                for (var i = 0; i < lines.length; i++) {
                    // Replace escaped colons in BSSID with placeholder
                    var line = lines[i].replace(/\\:/g, "##COLON##");
                    var parts = line.split(":");

                    if (parts.length >= 4 && parts[0]) {
                        var ssid = parts[0];
                        var signal = parseInt(parts[1]) || 0;
                        var security = parts[2] || "Open";
                        var inUse = parts[3].trim() === "*";
                        // Restore colons in BSSID
                        var bssid = (parts[4] || "").replace(/##COLON##/g, ":");
                        var freq = (parts[5] || "").replace(/##COLON##/g, "");
                        var rate = (parts[6] || "").replace(/##COLON##/g, "");

                        if (!networkMap[ssid] || networkMap[ssid].signal < signal) {
                            networkMap[ssid] = {
                                ssid: ssid,
                                signal: signal,
                                security: security === "--" ? "Open" : security,
                                connected: inUse,
                                bssid: bssid,
                                frequency: freq,
                                rate: rate
                            };
                        }

                        // Track connected network
                        if (inUse) {
                            foundConnected = true;
                            root.connectedSsid = ssid;
                            // Make sure connected network has connected flag even if not strongest signal
                            if (networkMap[ssid]) {
                                networkMap[ssid].connected = true;
                            }
                        }
                    }
                }

                if (!foundConnected) {
                    root.connectedSsid = "";
                }

                var networkArray = [];
                for (var key in networkMap) {
                    networkArray.push(networkMap[key]);
                }
                networkArray.sort(function(a, b) {
                    if (a.connected && !b.connected) return -1;
                    if (b.connected && !a.connected) return 1;
                    return b.signal - a.signal;
                });
                root.networks = networkArray;
                root.scanning = false;
            }
        }
    }

    // Rescan
    Process {
        id: rescanProc
        command: ["nmcli", "device", "wifi", "rescan"]
        onRunningChanged: {
            if (!running) {
                rescanDelayTimer.start();
            }
        }
    }

    Timer {
        id: rescanDelayTimer
        interval: 1500
        onTriggered: scanProc.running = true
    }

    // Connect
    Process {
        id: connectProc
        onRunningChanged: {
            if (!running) {
                scanProc.running = true;
                ipProc.running = true;
            }
        }
    }

    // Disconnect
    Process {
        id: disconnectProc
        command: ["nmcli", "device", "disconnect", "wlan0"]
        onRunningChanged: {
            if (!running) {
                root.connectedSsid = "";
                scanProc.running = true;
                ipProc.running = true;
            }
        }
    }

    // Check saved
    Process {
        id: checkSavedProc
        property var network: null
        property string outputBuffer: ""
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { checkSavedProc.outputBuffer += data; }
        }
        onRunningChanged: {
            if (running) { outputBuffer = ""; }
            else {
                var saved = outputBuffer.trim().split("\n");
                if (checkSavedProc.network && saved.indexOf(checkSavedProc.network.ssid) !== -1) {
                    root.connectToNetwork(checkSavedProc.network.ssid, "");
                } else {
                    root.currentView = "password";
                }
            }
        }
    }

    // Autoconnect toggle
    Process {
        id: autoconnectProc
        onRunningChanged: {
            if (!running) savedNetworksProc.running = true;
        }
    }

    // Forget network
    Process {
        id: forgetProc
        onRunningChanged: {
            if (!running) savedNetworksProc.running = true;
        }
    }

    // Reveal password
    Process {
        id: revealPassProc
        property var network: null
        property string outputBuffer: ""
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { revealPassProc.outputBuffer += data; }
        }
        onRunningChanged: {
            if (running) { outputBuffer = ""; }
            else {
                var password = outputBuffer.trim();
                var updated = root.savedNetworks.slice();
                for (var i = 0; i < updated.length; i++) {
                    if (updated[i].name === revealPassProc.network.name) {
                        updated[i] = Object.assign({}, updated[i], { revealedPassword: password });
                        break;
                    }
                }
                root.savedNetworks = updated;
            }
        }
    }

    // Get saved networks
    Process {
        id: savedNetworksProc
        property string outputBuffer: ""
        command: ["nmcli", "-t", "-f", "NAME,TYPE,AUTOCONNECT", "connection", "show"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { savedNetworksProc.outputBuffer += data; }
        }
        onRunningChanged: {
            if (running) { outputBuffer = ""; }
            else {
                var lines = outputBuffer.trim().split("\n");
                var saved = [];
                for (var i = 0; i < lines.length; i++) {
                    var parts = lines[i].split(":");
                    if (parts.length >= 3 && parts[1] === "802-11-wireless") {
                        saved.push({
                            name: parts[0],
                            type: parts[1],
                            autoconnect: parts[2] === "yes",
                            revealedPassword: null
                        });
                    }
                }
                root.savedNetworks = saved;
            }
        }
    }

    // Get local IP
    Process {
        id: ipProc
        property string outputBuffer: ""
        command: ["sh", "-c", "ip -4 route get 1.1.1.1 2>/dev/null | grep -oP 'src \\K[^ ]+' | head -1"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => { ipProc.outputBuffer += data; }
        }
        onRunningChanged: {
            if (running) { outputBuffer = ""; }
            else {
                var ip = outputBuffer.trim();
                root.localIp = ip || "Not connected";
            }
        }
    }

    // Periodic refresh
    Timer {
        interval: 5000
        running: root.visible && root.currentView === "main"
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (!root.scanning) {
                scanProc.running = true;
                ipProc.running = true;
                wifiStatusProc.running = true;
            }
        }
    }
}
