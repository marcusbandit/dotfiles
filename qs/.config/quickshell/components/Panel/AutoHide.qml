import QtQuick

// Auto-hide logic for the panel
Item {
    id: root

    anchors.fill: parent

    property int panelTargetHeight: 2
    property real panelSmoothHeight: 2

    signal requestExpand()
    signal requestCollapse()

    // Interaction lock - can be set by children to keep panel open
    property bool interactionLock: false

    // Hover state - set from Panel level
    property bool isHovered: false

    function stopCollapseTimer() {
        collapseTimer.stop();
    }

    function restartCollapseTimer() {
        collapseTimer.restart();
    }

    function checkShouldCollapse() {
        if (!isHovered && !interactionLock) {
            collapseTimer.restart();
        }
    }

    // Watch hover state
    onIsHoveredChanged: {
        if (isHovered) {
            root.requestExpand();
            collapseTimer.stop();
        } else if (!interactionLock) {
            collapseTimer.restart();
        }
    }

    // Watch interaction lock
    onInteractionLockChanged: {
        if (interactionLock) {
            root.requestExpand();
            collapseTimer.stop();
        } else if (!isHovered) {
            collapseTimer.restart();
        }
    }

    // Collapse timer
    Timer {
        id: collapseTimer
        interval: 300
        repeat: false
        onTriggered: {
            if (!root.isHovered && !root.interactionLock) {
                root.requestCollapse();
            }
        }
    }
}
