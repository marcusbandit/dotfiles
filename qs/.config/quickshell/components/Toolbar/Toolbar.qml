import QtQuick
import Quickshell
import Quickshell.Io
import "../../utils" as Utils
import "."

Item {
    id: toolbar
    anchors.fill: parent
    visible: panelImplicitHeight > 2

    property int panelImplicitHeight: 2
    property int monitorX: 0
    property int monitorY: 0
    property int monitorWidth: 0
    property int monitorHeight: 0
    property int panelTargetHeight: 2

    signal toggleWindowControls()

    // Theme properties
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#414868"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    // Load theme colors
    Utils.ThemeLoader {
        id: themeLoader
        onThemeBgChanged: toolbar.colBg = themeBg
        onThemeFgChanged: toolbar.colFg = themeFg
        onThemeMutedChanged: toolbar.colMuted = themeMuted
    }

    // Interaction lock - set to true when popups/menus are active
    property bool interactionLock: false

    // Track if mouse is over toolbar content
    property bool containsMouse: toolbarMouseArea.containsMouse
    
    // Network button hover state
    property bool networkButtonHovered: networkButton.isHovered
    property string networkName: networkButton.networkName
    property string localIp: networkButton.localIp
    property real networkButtonX: rightRow.x + networkButton.x + networkButton.width / 2

    property alias toolbarMouseArea: toolbarMouseArea

    MouseArea {
        id: toolbarMouseArea
        anchors.fill: parent
        hoverEnabled: true
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton
        z: -1
    }

    // LEFT: Active window title
    ActiveWindow {
        id: activeWindow
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        colBg: toolbar.colBg
        colFg: toolbar.colFg
        fontFamily: toolbar.fontFamily
        fontSize: toolbar.fontSize
    }

    // CENTER: Workspace selector
    WorkspaceSelector {
        id: workspaceSelector
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        colBg: toolbar.colBg
        colFg: toolbar.colFg
        colMuted: toolbar.colMuted
        fontFamily: toolbar.fontFamily
        fontSize: toolbar.fontSize
        onWorkspaceSelected: function(workspaceId) {
            switchWsProc.command = ["hyprctl", "dispatch", "workspace", workspaceId.toString()];
            switchWsProc.running = true;
        }
        onSpecialWorkspaceSelected: function(wsName) {
            switchWsProc.command = ["hyprctl", "dispatch", "togglespecialworkspace", wsName.replace("special:", "")];
            switchWsProc.running = true;
        }
    }

    Process {
        id: switchWsProc
    }

    // RIGHT: Volume, Network, Clock
    Row {
        id: rightRow
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        VolumeButton {
            id: volumeButton
            colBg: toolbar.colBg
            colFg: toolbar.colFg
            colMuted: toolbar.colMuted
            fontFamily: toolbar.fontFamily
            fontSize: toolbar.fontSize
        }

        BluetoothButton {
            id: bluetoothButton
            colBg: toolbar.colBg
            colFg: toolbar.colFg
            colMuted: toolbar.colMuted
            fontFamily: toolbar.fontFamily
            fontSize: toolbar.fontSize
        }

        NetworkButton {
            id: networkButton
            colBg: toolbar.colBg
            colFg: toolbar.colFg
            colMuted: toolbar.colMuted
            fontFamily: toolbar.fontFamily
            fontSize: toolbar.fontSize
        }

        Clock {
            id: clock
            colBg: toolbar.colBg
            colFg: toolbar.colFg
            colMuted: toolbar.colMuted
            fontFamily: toolbar.fontFamily
            fontSize: toolbar.fontSize
        }
    }

    // Expose hover states for other toolbar items
    property bool volumeButtonHovered: volumeButton.isHovered
    property bool bluetoothButtonHovered: bluetoothButton.isHovered
    property bool clockHovered: clock.isHovered
    property bool workspaceSelectorHovered: false  // WorkspaceSelector uses internal dots
    property bool statsHovered: false  // No stats display currently
}
