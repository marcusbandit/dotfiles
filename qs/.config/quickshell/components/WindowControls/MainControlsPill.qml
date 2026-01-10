import QtQuick

// Main controls pill component for window controls
Rectangle {
    id: root
    
    property var mainButtons: []
    property int windowControlsHeight: 40
    property color themeBg: "#1a1b26"
    property color themeFg: "#a9b1d6"
    property color themeAccent: "#7aa2f7"
    property color themeUrgent: "#f7768e"
    property color themeMuted: "#414868"
    property color themeBorder: "#565f89"
    property bool showAdjacentButtons: true
    
    signal buttonClicked(string cmd)
    signal buttonHover(string hoverMode)
    signal buttonHoverExit()
    
    height: root.windowControlsHeight
    width: mainButtonsRow.width
    color: root.themeBg
    border.color: root.themeBorder
    border.width: 1
    radius: height / 2
    
    Row {
        id: mainButtonsRow
        spacing: 2
        Repeater {
            model: root.mainButtons
            delegate: Rectangle {
                id: btn
                required property var modelData
                required property int index
                
                width: root.windowControlsHeight
                height: root.windowControlsHeight
                
                // Highlighting disabled (feature kept but not used)
                // Rounded highlight background with proper edge handling
                radius: 8
                topLeftRadius: index === 0 ? root.windowControlsHeight / 2 : 8
                bottomLeftRadius: index === 0 ? root.windowControlsHeight / 2 : 8
                topRightRadius: index === (root.mainButtons.length - 1) ? root.windowControlsHeight / 2 : 8
                bottomRightRadius: index === (root.mainButtons.length - 1) ? root.windowControlsHeight / 2 : 8
                
                color: {
                    // Highlighting disabled - always transparent
                    // if (modelData.cmd === "toggle_adj" && root.showAdjacentButtons)
                    //     return root.themeAccent;
                    // if (btnMa.containsMouse)
                    //     return modelData.urgent ? root.themeUrgent : root.themeMuted;
                    return "transparent";
                }
                
                Text {
                    anchors.centerIn: parent
                    text: modelData.icon
                    color: {
                        // Subtle hover feedback - just icon color change, no background
                        if (btnMa.containsMouse) {
                            return modelData.urgent ? root.themeUrgent : root.themeAccent;
                        }
                        return root.themeFg;
                    }
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 18
                    font.bold: true
                }
                
                MouseArea {
                    id: btnMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        // Target highlighting disabled - don't call buttonHover
                        // if (modelData.hover) {
                        //     root.buttonHover(modelData.hover);
                        // }
                    }
                    onExited: {
                        // Target highlighting disabled
                        // root.buttonHoverExit();
                    }
                    onClicked: {
                        root.buttonClicked(modelData.cmd);
                    }
                }
            }
        }
    }
}
