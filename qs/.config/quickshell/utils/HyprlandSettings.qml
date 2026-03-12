import QtQuick
import Quickshell.Io

// Fetches Hyprland settings (gaps, rounding) on launch
Item {
    id: root

    // Output properties
    property int gapsOut: 10  // Default fallback
    property int decorationRounding: 10  // Default fallback
    property int combinedRounding: gapsOut + decorationRounding

    // Fetch gaps_out
    Process {
        id: gapsProc
        command: ["sh", "-c", "hyprctl getoption general:gaps_out -j | jq -r '.custom' | cut -d' ' -f1"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let val = parseInt(data.trim());
                if (!isNaN(val)) {
                    root.gapsOut = val;
                }
            }
        }
    }

    // Fetch decoration:rounding
    Process {
        id: roundingProc
        command: ["sh", "-c", "hyprctl getoption decoration:rounding -j | jq -r '.int'"]
        running: true
        stdout: SplitParser {
            onRead: data => {
                let val = parseInt(data.trim());
                if (!isNaN(val)) {
                    root.decorationRounding = val;
                }
            }
        }
    }
}
