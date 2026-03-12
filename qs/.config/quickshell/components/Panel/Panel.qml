import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
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

    // Layer property - Overlay (3) is the highest, renders in front of popups
    property int panelLayer: 3  // Default to Overlay

    Component.onCompleted: {
        try {
            if (typeof WlrLayershell !== 'undefined' && WlrLayershell.Layer) {
                root.panelLayer = WlrLayershell.Layer.Overlay;
            }
        } catch(e) {}
    }

    WlrLayershell.layer: root.panelLayer

    anchors.top: true
    anchors.left: true
    anchors.right: true
    color: theme.colPanelBg
    
    // Theme and colors
    PanelTheme {
        id: theme
    }

    // Hyprland settings (gaps, rounding)
    Utils.HyprlandSettings {
        id: hyprSettings
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

    // Check if the focused workspace on this monitor has a fullscreen window
    property bool hasFullscreenOnMonitor: {
        for (let i = 0; i < Hyprland.workspaces.count; i++) {
            let ws = Hyprland.workspaces.get(i);
            if (ws && ws.monitor && ws.monitor.name === modelData.name && ws.focused && ws.hasFullscreen) {
                return true;
            }
        }
        return false;
    }

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
        hasFullscreen: root.hasFullscreenOnMonitor

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
    
    // WiFi Manager popup - now uses LayerShell on Top layer (behind panel)
    WiFiManager {
        id: wifiManager

        // Required properties for the new Scope-based WiFiManager
        panelScreen: root.screen
        xPosition: toolbar.networkButtonX
        panelHeight: root.implicitHeight
        cornerRadius: hyprSettings.combinedRounding

        colPopupBg: theme.colPopupBg
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
