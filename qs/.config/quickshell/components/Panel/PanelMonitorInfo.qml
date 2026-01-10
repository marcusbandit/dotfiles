import QtQuick
import "../../utils" as Utils

// Monitor information component
Item {
    id: root
    
    property string monitorName: ""
    property int monitorX: 0
    property int monitorY: 0
    property int monitorWidth: 0
    property int monitorHeight: 0
    
    Utils.MonitorInfo {
        id: monitorInfo
        monitorName: root.monitorName
        onMonitorXChanged: root.monitorX = monitorX
        onMonitorYChanged: root.monitorY = monitorY
        onMonitorWidthChanged: root.monitorWidth = monitorWidth
        onMonitorHeightChanged: root.monitorHeight = monitorHeight
    }
}
