pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Window
import QtQml
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../utils" as Utils
import "."

Scope {
    id: root
    
    property bool isExiting: false
    property int activeWindowX: 0
    property int activeWindowY: 0
    property int activeWindowW: 0
    property int activeWindowH: 0
    property string activeWindowAddr: ""
    property int activeMonitorId: -1
    property int activeWorkspaceId: -1
    property int windowControlsHeight: 40
    property real speed: isExiting ? 15.0 : 8.0
    property bool showAdjacentButtons: true
    
    // Target Highlight Properties
    property var targetRects: []
    property bool showTarget: false
    
    // Adjacency properties
    property var adjList: []
    property var activeScreen: null
    property int activeScreenX: 0
    property int activeScreenY: 0
    
    // Theme properties
    property color themeBg: "#1a1b26"
    property color themeFg: "#a9b1d6"
    property color themeAccent: "#7aa2f7"
    property color themeUrgent: "#f7768e"
    property color themeMuted: "#414868"
    property color themeBorder: "#565f89"
    
    // Button definitions
    property var mainButtons: [
        {
            "icon": "",
            "cmd": "fullscreen",
            "urgent": false,
            "hover": "target_self"
        },
        {
            "icon": "",
            "cmd": "togglefloating",
            "urgent": false,
            "hover": "target_self"
        },
        {
            "icon": "",
            "cmd": "togglesplit",
            "urgent": false,
            "hover": "target_split"
        },
        {
            "icon": "",
            "cmd": "pseudo",
            "urgent": false,
            "hover": "target_self"
        },
        {
            "icon": "",
            "cmd": "pin",
            "urgent": false,
            "hover": "target_self"
        },
        {
            "icon": "󰓡",
            "cmd": "toggle_adj",
            "urgent": false,
            "hover": ""
        },
        {
            "icon": "",
            "cmd": "killactive",
            "urgent": true,
            "hover": "target_self"
        }
    ]
    property var exitButtonDef: {
        "icon": "",
        "cmd": "close_widget",
        "urgent": false
    }
    
    // Load theme colors
    Utils.ThemeLoader {
        id: themeLoader
        onThemeBgChanged: root.themeBg = themeBg
        onThemeFgChanged: root.themeFg = themeFg
        onThemeAccentChanged: root.themeAccent = themeAccent
        onThemeUrgentChanged: root.themeUrgent = themeUrgent
        onThemeMutedChanged: root.themeMuted = themeMuted
        onThemeBorderChanged: root.themeBorder = themeBorder
    }
    
    // Hyprland commands helper
    Utils.HyprlandCommands {
        id: hyprlandCommands
    }
    
    function runDispatch(cmd) {
        hyprlandCommands.runDispatch(cmd);
    }
    
    function swapWindow(dir, target_centerX, target_centerY, current_centerX, current_centerY) {
        hyprlandCommands.swapWindow(dir, target_centerX, target_centerY, current_centerX, current_centerY);
    }
    
    // Helper to safely get Overlay layer
    property int overlayLayer: 2  // Default to Overlay layer (enum value 2)
    
    Component.onCompleted: {
        try {
            if (typeof WlrLayershell !== 'undefined' && WlrLayershell.Layer) {
                root.overlayLayer = WlrLayershell.Layer.Overlay;
            }
        } catch(e) {
            // Quiet warning - keep default value
        }
    }
    
    function updateAdjModel(newItems) {
        if (!root.showAdjacentButtons) newItems = [];
        
        let result = [];
        for (let i = 0; i < newItems.length; i++) {
            let item = newItems[i];
            result.push({
                adjKey: item.address + "_" + item.dir,
                adjDir: item.dir,
                adjDist: item.dist,
                adjX: item.x,
                adjY: item.y,
                adjW: item.w,
                adjH: item.h,
                adjFocusID: item.focusHistoryID
            });
        }
        root.adjList = result;
    }
    
    onShowAdjacentButtonsChanged: {
        if (!root.showAdjacentButtons) {
            updateAdjModel([]);
        } else {
            adjacentProc.running = false;
            adjacentProc.running = true;
        }
    }
    
    // Process to list adjacent windows
    Process {
        id: adjacentProc
        command: ["python3", "/home/bandit/.config/quickshell/scripts/list_adjacent.py"]
        stdout: SplitParser {
            onRead: data => {
                let lines = data.trim().split("\n");
                for (let i = 0; i < lines.length; i++) {
                    let line = lines[i];
                    if (line.startsWith("ADJACENT:")) {
                        try {
                            let jsonStr = line.substring(9);
                            let parsed = JSON.parse(jsonStr);
                            root.updateAdjModel(parsed);
                        } catch (e) {
                            console.log("Error parsing adjacency: " + e);
                        }
                    }
                }
            }
        }
    }
    
    // Get active window position and monitor
    Process {
        id: posProcess
        command: ["sh", "-c", "hyprctl activewindow -j > /tmp/qs_aw.json && hyprctl clients -j > /tmp/qs_c.json && jq -n -c --slurpfile aw /tmp/qs_aw.json --slurpfile c /tmp/qs_c.json '{at: $aw[0].at, size: $aw[0].size, monitor: $aw[0].monitor, ws: $aw[0].workspace.id, addr: $aw[0].address}'"]
        running: true
        
        stdout: SplitParser {
            onRead: data => {
                let parsed = JSON.parse(data.trim());
                if (parsed) {
                    let geomChanged = root.activeWindowX !== parsed.at[0] || root.activeWindowY !== parsed.at[1] || root.activeWindowW !== parsed.size[0] || root.activeWindowH !== parsed.size[1];
                    
                    root.activeWindowX = parsed.at[0];
                    root.activeWindowY = parsed.at[1];
                    root.activeWindowW = parsed.size[0];
                    root.activeWindowH = parsed.size[1];
                    root.activeMonitorId = parsed.monitor;
                    root.activeWorkspaceId = parsed.ws;
                    
                    if (root.activeWindowAddr !== parsed.addr || geomChanged) {
                        root.activeWindowAddr = parsed.addr;
                        adjacentProc.running = false;
                        adjacentProc.running = true;
                    }
                }
            }
        }
    }
    
    Timer {
        interval: 100
        running: true
        repeat: true
        onTriggered: {
            posProcess.running = false;
            posProcess.running = true;
        }
    }
    
    function detectTarget(mode) {
        let jqScript = "($aw[0]) as $me | ($me.workspace.id) as $ws | ($c[0] | map(select(.workspace.id == $ws and .floating == false and .address != $me.address))) as $others | ";
        if (mode === "target_split") {
            jqScript += "($others | map(select(((.at[1] - $me.at[1]) | length < 5) and ((.size[1] - $me.size[1]) | length < 5)))) as $row_sibs | ($others | map(select(((.at[0] - $me.at[0]) | length < 5) and ((.size[0] - $me.size[0]) | length < 5)))) as $col_sibs | (if ($row_sibs | length) > 0 then ([$me] + $row_sibs) elif ($col_sibs | length) > 0 then ([$me] + $col_sibs) else [$me] end) as $group | $group | map({x: .at[0], y: .at[1], w: .size[0], h: .size[1]})";
        } else if (mode === "target_self") {
            jqScript += "[{x: $me.at[0], y: $me.at[1], w: $me.size[0], h: $me.size[1]}]";
        }
        
        targetProc.command = ["sh", "-c", "hyprctl activewindow -j > /tmp/qs_aw.json && hyprctl clients -j > /tmp/qs_c.json && jq -n -c --slurpfile aw /tmp/qs_aw.json --slurpfile c /tmp/qs_c.json '" + jqScript + "'"];
        targetProc.running = false;
        targetProc.running = true;
    }
    
    // Process to find target window for swap/split
    Process {
        id: targetProc
        stdout: SplitParser {
            onRead: data => {
                let rects = JSON.parse(data.trim());
                if (rects && rects.length > 0) {
                    root.targetRects = rects;
                    root.showTarget = true;
                }
            }
        }
    }
    
    // Monitor Panels (Main Controls)
    Variants {
        model: Quickshell.screens
        
        delegate: Component {
            PanelWindow {
                id: panelWindow
                required property var modelData
                
                property int monitorId: 0
                property int monitorX: 0
                property int monitorY: 0
                
                property bool isActiveMonitor: root.activeMonitorId === monitorId
                property bool wasActiveMonitor: false
                
                // Smoothed position properties
                property real smoothX: 0
                property real smoothY: 0
                property bool initialized: false
                
                // Reset initialized when monitor becomes active
                onIsActiveMonitorChanged: {
                    if (isActiveMonitor) {
                        root.activeScreen = panelWindow.screen;
                        root.activeScreenX = panelWindow.monitorX;
                        root.activeScreenY = panelWindow.monitorY;
                    }
                    
                    if (isActiveMonitor && !wasActiveMonitor) {
                        initialized = false;
                    }
                    wasActiveMonitor = isActiveMonitor;
                }
                
                screen: modelData
                WlrLayershell.layer: root.overlayLayer
                
                anchors {
                    left: true
                    right: true
                    top: true
                    bottom: true
                }
                
                color: "transparent"
                
                mask: Region {
                    item: controlContainer
                }
                
                // Get monitor info for this screen
                Process {
                    id: monitorInfoProcess
                    command: ["sh", "-c", "hyprctl monitors -j | jq -c '.[] | select(.name == \"" + panelWindow.modelData.name + "\") | {id: .id, x: .x, y: .y}'"]
                    running: true
                    
                    stdout: SplitParser {
                        onRead: data => {
                            let info = JSON.parse(data.trim());
                            panelWindow.monitorId = info.id;
                            panelWindow.monitorX = info.x;
                            panelWindow.monitorY = info.y;
                            
                            if (root.activeMonitorId === info.id) {
                                root.activeScreen = panelWindow.screen;
                                root.activeScreenX = info.x;
                                root.activeScreenY = info.y;
                            }
                        }
                    }
                }
                
                // Smooth animation timer (runs at ~60fps)
                Timer {
                    interval: 16
                    running: true
                    repeat: true
                    onTriggered: {
                        if (!panelWindow.isActiveMonitor)
                            return;
                        let targetX = root.activeWindowX - panelWindow.monitorX + 30;
                        let targetY = root.activeWindowY - panelWindow.monitorY + 30;
                        
                        if (root.isExiting) {
                            targetY = -200;
                        }
                        
                        // Initialize on first run to avoid animating from 0,0
                        if (!panelWindow.initialized && root.activeWindowX !== 0) {
                            panelWindow.smoothX = targetX;
                            panelWindow.smoothY = targetY;
                            panelWindow.initialized = true;
                            return;
                        }
                        
                        let dt = interval / 1000.0;
                        
                        // Exponential smoothing
                        let factor = 1 - Math.exp(-root.speed * dt);
                        panelWindow.smoothX += (targetX - panelWindow.smoothX) * factor;
                        panelWindow.smoothY += (targetY - panelWindow.smoothY) * factor;
                        
                        // Only animate out if exit button was clicked (closes widget), not when killing windows
                        // The actual closing is handled by the Loader in shell.qml
                        if (root.isExiting && panelWindow.smoothY < -100) {
                            // Animation complete - reset state
                            root.isExiting = false;
                        }
                    }
                }
                
                Item {
                    id: controlContainer
                    x: panelWindow.smoothX
                    y: panelWindow.smoothY
                    width: controlsRow.width
                    height: root.windowControlsHeight
                    visible: panelWindow.isActiveMonitor
                    
                    Row {
                        id: controlsRow
                        spacing: 8
                        
                        MainControlsPill {
                            id: mainPill
                            mainButtons: root.mainButtons
                            windowControlsHeight: root.windowControlsHeight
                            themeBg: root.themeBg
                            themeFg: root.themeFg
                            themeAccent: root.themeAccent
                            themeUrgent: root.themeUrgent
                            themeMuted: root.themeMuted
                            themeBorder: root.themeBorder
                            showAdjacentButtons: root.showAdjacentButtons
                            
                            onButtonClicked: function(cmd) {
                                if (cmd === "toggle_adj") {
                                    root.showAdjacentButtons = !root.showAdjacentButtons;
                                } else {
                                    root.runDispatch(cmd);
                                    // Don't set isExiting for killactive - only kill the window, not the shell
                                }
                            }
                            
                            onButtonHover: function(mode) {
                                // Target highlighting disabled - feature kept but not used
                                // root.detectTarget(mode);
                            }
                            
                            onButtonHoverExit: function() {
                                // Target highlighting disabled
                                // root.showTarget = false;
                            }
                        }
                        
                        ExitButton {
                            id: exitPill
                            windowControlsHeight: root.windowControlsHeight
                            themeBg: root.themeBg
                            themeFg: root.themeFg
                            themeAccent: root.themeAccent
                            themeBorder: root.themeBorder
                            exitIcon: root.exitButtonDef.icon
                            
                            onClicked: {
                                // Exit button closes the window controls widget, not the shell
                                root.isExiting = true;
                            }
                        }
                    }
                }
                
                // Target Highlight Overlay - disabled (feature kept but not used)
                // TargetHighlight {
                //     id: highlightContainer
                //     targetRects: root.targetRects
                //     showTarget: root.showTarget
                //     monitorX: panelWindow.monitorX
                //     monitorY: panelWindow.monitorY
                //     themeAccent: root.themeAccent
                // }
            }
        }
    }
    
    // Adjacent Buttons (Separate Overlay Windows)
    AdjacentButtons {
        id: adjacentButtons
        adjList: root.adjList
        activeScreen: root.activeScreen
        activeScreenX: root.activeScreenX
        activeScreenY: root.activeScreenY
        activeWindowX: root.activeWindowX
        activeWindowY: root.activeWindowY
        activeWindowW: root.activeWindowW
        activeWindowH: root.activeWindowH
        windowControlsHeight: root.windowControlsHeight
        themeBg: root.themeBg
        themeFg: root.themeFg
        themeAccent: root.themeAccent
        themeMuted: root.themeMuted
        themeBorder: root.themeBorder
        overlayLayer: root.overlayLayer
        
        onSwapRequested: function(dir, targetX, targetY, currentX, currentY) {
            root.swapWindow(dir, targetX, targetY, currentX, currentY);
        }
    }
}
