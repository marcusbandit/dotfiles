import QtQuick

// Target highlight overlay component
Item {
    id: root
    
    property var targetRects: []
    property bool showTarget: false
    property int monitorX: 0
    property int monitorY: 0
    property color themeAccent: "#7aa2f7"
    
    anchors.fill: parent
    visible: root.showTarget && targetRects.length > 0
    
    Repeater {
        model: root.targetRects
        delegate: Rectangle {
            x: modelData.x - root.monitorX
            y: modelData.y - root.monitorY
            width: modelData.w
            height: modelData.h
            color: Qt.rgba(root.themeAccent.r, root.themeAccent.g, root.themeAccent.b, 0.25)
            border.color: root.themeAccent
            border.width: 3
        }
    }
}
