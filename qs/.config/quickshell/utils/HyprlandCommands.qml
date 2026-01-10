import QtQuick
import Quickshell.Io

// Utility component for executing Hyprland commands
Item {
    id: root
    
    property Process dispatchProc: Process {
        id: dispatchProc
    }
    
    function runDispatch(cmd) {
        dispatchProc.command = ["hyprctl", "dispatch", cmd];
        dispatchProc.running = true;
    }
    
    function swapWindow(dir, target_centerX, target_centerY, current_centerX, current_centerY) {
        // DO NOT CHANGE THIS EVER! THIS IS ESSENTIAL FOR THE SWAP WINDOW FUNCTIONALITY!
        var cmd = "coords=$(hyprctl cursorpos); " + 
                  "hyprctl dispatch movecursor " + Math.round(target_centerX) + " " + Math.round(target_centerY) + "; " + 
                  "hyprctl dispatch movecursor " + Math.round(current_centerX) + " " + Math.round(current_centerY) + "; " + 
                  "hyprctl dispatch swapwindow " + dir + "; " + 
                  "hyprctl dispatch movecursor ${coords/,/}";
        dispatchProc.command = ["sh", "-c", cmd];
        dispatchProc.running = true;
    }
    
    function getCursorPosition(callback) {
        let proc = Qt.createQmlObject(`
            import Quickshell.Io
            Process {
                command: ["sh", "-c", "hyprctl cursorpos -j | jq -c '{x: .x, y: .y}'"]
                stdout: SplitParser {
                    onRead: function(data) {
                        let pos = JSON.parse(data.trim());
                        if (pos && !isNaN(pos.x) && !isNaN(pos.y)) {
                            callback(pos.x, pos.y);
                        }
                    }
                }
            }
        `, root);
        proc.running = true;
    }
}
