import QtQuick

// Hover popup component that appears below the panel as a small notch
Rectangle {
    id: root
    
    // Content container - children can be added here
    default property alias content: contentContainer.children
    
    // Visibility control
    property bool show: false
    
    // Panel reference - should be set to the Panel component
    property var panel: null
    
    // Horizontal position (x coordinate) - defaults to right side
    property real xPosition: 0
    
    // Theme properties
    property color colBg: "#1a1b26"
    property color colFg: "#a9b1d6"
    property color colMuted: "#565f89"
    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14
    
    // Position below panel
    x: panel ? (xPosition > 0 ? xPosition - width / 2 : panel.width - width - 12) : 0
    y: panel ? panel.height : 0
    
    // Small notch width - auto-sized based on content
    width: Math.max(contentContainer.implicitWidth + 16, 120)
    height: contentContainer.implicitHeight + 16
    
    color: colBg
    radius: 8
    
    // Content container - use Item wrapper to avoid Column anchor issues
    Item {
        id: contentWrapper
        anchors.fill: parent
        anchors.margins: 8
        
        Column {
            id: contentContainer
            width: parent.width
            spacing: 4
        }
    }
    
    // Fade in/out animation
    opacity: show ? 1 : 0
    Behavior on opacity {
        NumberAnimation { duration: 200 }
    }
    
    // Make it not take up space when invisible
    visible: show && opacity > 0
    
    // Ensure it's above other content
    z: 1000
}
