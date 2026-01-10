import QtQuick
import Quickshell
import Quickshell.Wayland

// Adjacent window buttons component
Variants {
    id: root
    
    property var adjList: []
    property var activeScreen: null
    property int activeScreenX: 0
    property int activeScreenY: 0
    property int activeWindowX: 0
    property int activeWindowY: 0
    property int activeWindowW: 0
    property int activeWindowH: 0
    property int windowControlsHeight: 40
    property color themeBg: "#1a1b26"
    property color themeFg: "#a9b1d6"
    property color themeAccent: "#7aa2f7"
    property color themeMuted: "#414868"
    property color themeBorder: "#565f89"
    property int overlayLayer: 2
    
    signal swapRequested(string dir, real targetX, real targetY, real currentX, real currentY)
    
    model: root.adjList
    
    delegate: Component {
        PanelWindow {
            id: adjWindow
            required property var modelData
            
            visible: root.activeScreen !== null
            screen: root.activeScreen
            
            WlrLayershell.layer: root.overlayLayer
            
            anchors {
                left: true
                right: true
                top: true
                bottom: true
            }
            
            color: "transparent"
            
            mask: Region {
                item: adjBtn
            }
            
            Rectangle {
                id: adjBtn
                
                property int btnSize: root.windowControlsHeight
                property string dir: adjWindow.modelData.adjDir
                property int dist: adjWindow.modelData.adjDist
                property int ax: adjWindow.modelData.adjX
                property int ay: adjWindow.modelData.adjY
                property int aw: adjWindow.modelData.adjW
                property int ah: adjWindow.modelData.adjH
                property string key: adjWindow.modelData.adjKey
                
                width: btnSize
                height: btnSize
                radius: 8
                
                color: ma.containsMouse ? root.themeMuted : root.themeBg
                border.color: ma.containsMouse ? root.themeAccent : root.themeBorder
                border.width: 1
                
                x: {
                    if (!root.activeScreen) return 0;
                    let center = 0;
                    let actX = root.activeWindowX;
                    let actW = root.activeWindowW;
                    
                    if (dir === "l")
                        center = ax + aw + (dist / 2);
                    else if (dir === "r")
                        center = ax - (dist / 2);
                    else {
                        let start = Math.max(ax, actX);
                        let end = Math.min(ax + aw, actX + actW);
                        center = (start + end) / 2;
                    }
                    return center - root.activeScreenX - (width / 2);
                }
                
                y: {
                    if (!root.activeScreen) return 0;
                    let center = 0;
                    let actY = root.activeWindowY;
                    let actH = root.activeWindowH;
                    
                    if (dir === "u")
                        center = ay + ah + (dist / 2);
                    else if (dir === "d")
                        center = ay - (dist / 2);
                    else {
                        let start = Math.max(ay, actY);
                        let end = Math.min(ay + ah, actY + actH);
                        center = (start + end) / 2;
                    }
                    return center - root.activeScreenY - (height / 2);
                }
                
                Text {
                    anchors.centerIn: parent
                    text: (adjBtn.dir === "l" || adjBtn.dir === "r") ? "󰓡" : "󰓢"
                    rotation: (adjBtn.dir === "l" || adjBtn.dir === "u") ? 180 : 0
                    color: ma.containsMouse ? "white" : root.themeFg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20
                    font.bold: true
                }
                
                MouseArea {
                    id: ma
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        let target_centerX = adjBtn.ax + (adjBtn.aw / 2);
                        let target_centerY = adjBtn.ay + (adjBtn.ah / 2);
                        let current_centerX = root.activeWindowX + (root.activeWindowW / 2);
                        let current_centerY = root.activeWindowY + (root.activeWindowH / 2);
                        root.swapRequested(adjBtn.dir, target_centerX, target_centerY, current_centerX, current_centerY);
                    }
                }
            }
        }
    }
}
