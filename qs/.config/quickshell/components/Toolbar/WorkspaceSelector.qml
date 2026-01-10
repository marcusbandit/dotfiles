import QtQuick
import Quickshell.Io
import "."

// Workspace selector with special workspaces pill, main 10-dot pill, and icon button
Item {
    id: root

    property int currentWorkspace: 1
    property var occupiedWorkspaces: []
    property var specialWorkspaces: []        // List of special workspace names
    property string activeSpecialWs: ""       // Currently active special workspace

    // Theme
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colActive: "#7aa2f7"
    property color colOccupied: "#565f89"
    property color colEmpty: "#24283b"
    property color colHover: "#9aa5ce"
    property color colMuted: "#414868"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    signal workspaceSelected(int workspaceId)
    signal specialWorkspaceSelected(string wsName)

    anchors.horizontalCenter: parent.horizontalCenter
    anchors.verticalCenter: parent.verticalCenter
    width: mainRow.width
    height: 38

    // Query occupied workspaces (regular, id > 0)
    Process {
        id: workspaceProc
        command: ["sh", "-c", "hyprctl workspaces -j | jq -c '[.[] | select(.id > 0) | .id] | sort'"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.occupiedWorkspaces = JSON.parse(data.trim());
                } catch(e) {
                    root.occupiedWorkspaces = [];
                }
            }
        }
    }

    // Query current workspace
    Process {
        id: activeWsProc
        command: ["sh", "-c", "hyprctl activeworkspace -j | jq '.id'"]
        stdout: SplitParser {
            onRead: data => {
                let ws = parseInt(data.trim());
                if (!isNaN(ws)) root.currentWorkspace = ws;
            }
        }
    }

    // Query special workspaces
    Process {
        id: specialWsProc
        command: ["sh", "-c", "hyprctl workspaces -j | jq -c '[.[] | .name | select(startswith(\"special:\"))]'"]
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.specialWorkspaces = JSON.parse(data.trim());
                } catch(e) {
                    root.specialWorkspaces = [];
                }
            }
        }
    }

    // Query active special workspace on focused monitor
    Process {
        id: activeSpecialProc
        command: ["sh", "-c", "hyprctl monitors -j | jq -r '.[] | select(.focused) | .specialWorkspace.name'"]
        stdout: SplitParser {
            onRead: data => {
                root.activeSpecialWs = data.trim();
            }
        }
    }

    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            workspaceProc.running = true;
            activeWsProc.running = true;
            specialWsProc.running = true;
            activeSpecialProc.running = true;
        }
    }

    Component.onCompleted: {
        workspaceProc.running = true;
        activeWsProc.running = true;
        specialWsProc.running = true;
        activeSpecialProc.running = true;
    }

    Row {
        id: mainRow
        anchors.centerIn: parent
        spacing: 8

        // Special workspaces pill (left) - only shown if there are special workspaces
        Rectangle {
            id: specialPill
            visible: root.specialWorkspaces.length > 0
            width: visible ? specialDotsRow.width + 28 : 0
            height: 38
            radius: 19
            color: root.colBg

            Row {
                id: specialDotsRow
                anchors.centerIn: parent
                spacing: 6

                Repeater {
                    model: root.specialWorkspaces
                    WorkspaceDot {
                        required property var modelData
                        required property int index
                        workspaceId: -1  // Special workspaces use name, not id
                        isActive: root.activeSpecialWs === modelData
                        isOccupied: true  // Special workspaces are always "occupied" if they exist
                        colActive: root.colActive
                        colOccupied: root.colOccupied
                        colEmpty: root.colEmpty
                        colHover: root.colHover
                        fullSize: 10

                        onClicked: {
                            root.specialWorkspaceSelected(modelData);
                        }
                    }
                }
            }
        }

        // Main workspaces pill (10 dots)
        Rectangle {
            id: mainPill
            width: mainDotsRow.width + 28
            height: 38
            radius: 19
            color: root.colBg

            Row {
                id: mainDotsRow
                anchors.centerIn: parent
                spacing: 6

                Repeater {
                    model: 10
                    WorkspaceDot {
                        required property int index
                        property int wsId: index + 1
                        workspaceId: wsId
                        isActive: wsId === root.currentWorkspace
                        isOccupied: root.occupiedWorkspaces.indexOf(wsId) !== -1
                        colActive: root.colActive
                        colOccupied: root.colOccupied
                        colEmpty: root.colEmpty
                        colHover: root.colHover

                        onClicked: {
                            root.workspaceSelected(wsId);
                        }
                    }
                }
            }
        }

        // Icon button (right)
        Rectangle {
            id: iconButton
            width: 38
            height: 38
            radius: 19
            color: iconButtonMa.containsMouse ? root.colMuted : root.colBg

            Text {
                anchors.centerIn: parent
                text: "󰕰"
                color: root.colFg
                font.family: root.fontFamily
                font.pixelSize: 18
            }

            MouseArea {
                id: iconButtonMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    // TODO: Implement icon button functionality
                }
            }
        }
    }
}
