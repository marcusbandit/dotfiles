import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import "components/Panel"

// Main shell entry point - creates panels for each screen
Variants {
    model: Quickshell.screens
    
    delegate: Component {
        Panel {
            // modelData is automatically provided by Variants to required properties
        }
    }
}
