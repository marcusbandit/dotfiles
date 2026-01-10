import QtQuick

// Window Controls loader component
Loader {
    id: root
    
    property bool shouldLoad: false
    
    active: root.shouldLoad
    source: "components/WindowControls/WindowControls.qml"
    
    // When window controls wants to exit (exit button clicked), deactivate the loader
    onItemChanged: {
        if (item) {
            item.isExitingChanged.connect(function() {
                if (item.isExiting) {
                    root.shouldLoad = false;
                    // Reset the isExiting flag after closing
                    Qt.callLater(function() {
                        if (item) item.isExiting = false;
                    });
                }
            });
        }
    }
}
