import QtQuick
import Quickshell.Io

// Utility component for getting monitor information from Hyprland
Item {
    id: root
    
    property string monitorName: ""
    property int monitorId: -1
    property int monitorX: 0
    property int monitorY: 0
    property int monitorWidth: 0
    property int monitorHeight: 0
    
    // Get monitor position and size from hyprctl
    Process {
        id: monitorInfoProc
        command: ["sh", "-c", "hyprctl monitors -j | jq -c '.[] | select(.name == \"" + root.monitorName + "\") | {id: .id, x: .x, y: .y, width: .width, height: .height}'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let info = JSON.parse(data.trim());
                if (info) {
                    root.monitorId = info.id || -1;
                    root.monitorX = info.x || 0;
                    root.monitorY = info.y || 0;
                    root.monitorWidth = info.width || 0;
                    root.monitorHeight = info.height || 0;
                }
            }
        }
    }
    
    function refresh() {
        monitorInfoProc.running = false;
        monitorInfoProc.running = true;
    }
}
