import QtQuick

// Background rectangle with rounded bottom corners
Rectangle {
    anchors.fill: parent
    color: colPanelBg
    topLeftRadius: 0
    topRightRadius: 0
    bottomLeftRadius: 12
    bottomRightRadius: 12
    
    property color colPanelBg: "#00000000"
}
