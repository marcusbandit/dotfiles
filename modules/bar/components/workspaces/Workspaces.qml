pragma ComponentBehavior: Bound

import qs.services
import qs.config
import qs.components
import Quickshell
import QtQuick
import QtQuick.Layouts

StyledRect {
    id: root

    required property ShellScreen screen

    readonly property int activeWsId: Config.bar.workspaces.perMonitorWorkspaces ? (Hyprland.monitorFor(screen).activeWorkspace?.id ?? 1) : Hyprland.activeWsId

    readonly property var occupied: Hyprland.workspaces.values.reduce((acc, curr) => {
        acc[curr.id] = curr.lastIpcObject.windows > 0;
        return acc;
    }, {})
    readonly property int groupOffset: Math.floor((activeWsId - 1) / Config.bar.workspaces.shown) * Config.bar.workspaces.shown

    implicitHeight: layout.implicitHeight + Appearance.padding.small * 2
    implicitWidth: Config.bar.sizes.innerWidth

    color: Colours.tPalette.m3surfaceContainer
    radius: Appearance.rounding.full

    Loader {
        active: Config.bar.workspaces.occupiedBg
        asynchronous: true

        anchors.fill: parent
        anchors.margins: Appearance.padding.small

        sourceComponent: OccupiedBg {
            workspaces: workspaces
            occupied: root.occupied
            groupOffset: root.groupOffset
        }
    }

    ColumnLayout {
        id: layout

        anchors.centerIn: parent
        spacing: Math.floor(Appearance.spacing.small / 2)

        Repeater {
            id: workspaces

            model: Config.bar.workspaces.shown

            Workspace {
                activeWsId: root.activeWsId
                occupied: root.occupied
                groupOffset: root.groupOffset
            }
        }
    }

    Loader {
        anchors.horizontalCenter: parent.horizontalCenter
        active: Config.bar.workspaces.activeIndicator
        asynchronous: true

        sourceComponent: ActiveIndicator {
            activeWsId: root.activeWsId
            workspaces: workspaces
            mask: layout
        }
    }
}
