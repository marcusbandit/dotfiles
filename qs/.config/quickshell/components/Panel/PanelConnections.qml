import QtQuick

// Panel connections and event handlers
Item {
    id: root

    property var toolbar: null

    signal toggleWindowControls()

    Connections {
        target: root.toolbar
        enabled: root.toolbar !== null

        function onToggleWindowControls() {
            root.toggleWindowControls();
        }
    }
}
