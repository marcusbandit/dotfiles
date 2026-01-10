import Quickshell
import Quickshell.Wayland
import QtQuick
import "."
import "../Toolbar"
import "../WindowControls"
import "../../utils" as Utils

// Main panel component
PanelWindow {
    id: root
    
    required property var modelData
    
    // Assign modelData (the screen from Variants) to PanelWindow's screen property
    screen: modelData
    
    anchors.top: true
    anchors.left: true
    anchors.right: true
    color: theme.colPanelBg
    
    // Theme and colors
    PanelTheme {
        id: theme
    }
    
    // Monitor information
    PanelMonitorInfo {
        id: monitorInfo
        monitorName: modelData.name
    }
    
    property int monitorX: monitorInfo.monitorX
    property int monitorY: monitorInfo.monitorY
    property int monitorWidth: monitorInfo.monitorWidth
    property int monitorHeight: monitorInfo.monitorHeight
    
    property int panelTargetHeight: 57 // Start expanded (1.5x scale)
    property real panelSmoothHeight: 57 // Start expanded (1.5x scale)
    implicitHeight: Math.round(panelSmoothHeight)
    
    // Panel animation
    PanelAnimation {
        id: animation
        panelTargetHeight: root.panelTargetHeight
        onPanelSmoothHeightChanged: {
            root.panelSmoothHeight = animation.panelSmoothHeight;
        }
    }
    
    // Background
    PanelBackground {
        colPanelBg: theme.colPanelBg
        z: -2
    }
    
    // Expose interaction lock for child components (popups, menus, etc.)
    property alias interactionLock: autoHide.interactionLock

    // Auto-hide logic
    AutoHide {
        id: autoHide
        panelTargetHeight: root.panelTargetHeight
        panelSmoothHeight: root.panelSmoothHeight
        isHovered: panelHoverDetector.hovered

        onRequestExpand: {
            root.panelTargetHeight = 57;
        }

        onRequestCollapse: {
            root.panelTargetHeight = 2;
        }
    }

    // Toolbar
    Toolbar {
        id: toolbar
        panelImplicitHeight: root.implicitHeight
        colBg: theme.colBg
        colFg: theme.colFg
        colMuted: theme.colMuted
        fontFamily: theme.fontFamily
        fontSize: theme.fontSize
        monitorX: root.monitorX
        monitorY: root.monitorY
        monitorWidth: root.monitorWidth
        monitorHeight: root.monitorHeight
        panelTargetHeight: root.panelTargetHeight
        z: 1

        // Direct binding: toolbar interaction lock controls panel auto-hide
        onInteractionLockChanged: {
            autoHide.interactionLock = toolbar.interactionLock;
        }
    }

    // TOP-LEVEL hover detector - HoverHandler doesn't block child hover events
    HoverHandler {
        id: panelHoverDetector
    }
    
    property bool windowControlsActive: false
    
    // Panel connections and event handlers
    PanelConnections {
        id: panelConnections
        toolbar: toolbar

        onToggleWindowControls: {
            root.windowControlsActive = !root.windowControlsActive;
        }
    }
    
    // Window Controls - loaded on demand
    WindowControlsLoader {
        shouldLoad: root.windowControlsActive
    }
    
    // WiFi Manager popup
    WiFiManager {
        id: wifiManager
        anchor.window: root
        anchor.rect.x: toolbar.networkButtonX - 160  // Center popup on button (320/2 = 160)
        anchor.rect.y: root.implicitHeight
        anchor.edges: Edges.Top | Edges.Left

        colBg: theme.colBg
        colFg: theme.colFg
        colMuted: theme.colMuted
        colActive: theme.colBlue
        colHover: theme.colMuted
        fontFamily: theme.fontFamily
        fontSize: theme.fontSize

        visible: wifiPopupController.showPopup

        onRequestClose: {
            wifiPopupController.showPopup = false;
            autoHide.interactionLock = false;
        }
    }

    // Controller for WiFi popup visibility
    // Stays open until: hovering another panel item OR pressing escape
    Item {
        id: wifiPopupController
        property bool showPopup: false
        property bool buttonHovered: toolbar.networkButtonHovered
        property bool popupHovered: wifiManager.isHovered

        // Track if other panel items are hovered (close popup if so)
        property bool otherPanelItemHovered: toolbar.volumeButtonHovered ||
                                              toolbar.bluetoothButtonHovered ||
                                              toolbar.clockHovered ||
                                              toolbar.workspaceSelectorHovered ||
                                              toolbar.statsHovered

        // Show popup when button is hovered
        onButtonHoveredChanged: {
            if (buttonHovered && !showPopup) {
                showDelayTimer.start();
            }
        }

        // Close popup when hovering other panel items
        onOtherPanelItemHoveredChanged: {
            if (otherPanelItemHovered && showPopup) {
                showPopup = false;
                autoHide.interactionLock = false;
            }
        }

        Timer {
            id: showDelayTimer
            interval: 150
            onTriggered: {
                if (wifiPopupController.buttonHovered) {
                    wifiPopupController.showPopup = true;
                    autoHide.interactionLock = true;
                }
            }
        }
    }
}
