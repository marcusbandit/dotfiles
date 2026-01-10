import QtQuick

// Exponential smoothing animation for panel height
Item {
    id: root
    
    property int panelTargetHeight: 38
    property real panelSmoothHeight: 38
    property real panelSpeed: 40.0
    
    // Exponential smoothing animation for panel height
    Timer {
        interval: 16 // ~60fps
        running: true
        repeat: true
        onTriggered: {
            let dt = interval / 1000.0; // Convert ms to seconds
            let factor = 1 - Math.exp(-root.panelSpeed * dt);
            root.panelSmoothHeight += (root.panelTargetHeight - root.panelSmoothHeight) * factor;
        }
    }
    
    // Expose smooth height changes
    onPanelSmoothHeightChanged: {
        // This allows parent to bind to the value
    }
}
