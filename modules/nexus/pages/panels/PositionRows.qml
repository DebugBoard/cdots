pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components.controls
import qs.modules.nexus.common

// One row per connected monitor, letting a panel be docked to either side of
// each screen independently. Writes land in that monitor's config layer.
Repeater {
    id: root

    // Config subobject holding the position, e.g. "bar" or "sidebar"
    required property string configKey

    model: Quickshell.screens

    delegate: SelectRow {
        id: row

        required property int index
        required property ShellScreen modelData

        readonly property list<MenuItem> positions: [
            MenuItem {
                text: qsTr("Left")
                icon: "dock_to_left"
            },
            MenuItem {
                text: qsTr("Right")
                icon: "dock_to_right"
            }
        ]

        first: index === 0
        last: index === root.count - 1
        label: modelData.name
        subtext: modelData.model
        menuItems: positions
        active: positions[GlobalConfig.forScreen(modelData.name)[root.configKey].position]
        onSelected: item => {
            GlobalConfig.forScreen(row.modelData.name)[root.configKey].position = row.positions.indexOf(item);
        }
    }
}
