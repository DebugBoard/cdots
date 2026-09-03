pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.modules.bar as Bar

Region {
    id: root

    required property Bar.BarWrapper bar
    required property Panels panels
    required property var win

    readonly property real borderThickness: win.contentItem.Config.border.thickness
    readonly property real clampedThickness: win.contentItem.Config.border.clampedThickness
    readonly property bool barOnRight: win.contentItem.Config.bar.position === PanelPosition.Right
    readonly property bool sidebarOnLeft: win.contentItem.Config.sidebar.position === PanelPosition.Left

    // Gap between the sidebar's screen edge and the drawer area, so the sidebar panels'
    // masks reach the edge. Just the border, unless the bar is docked on that same side.
    readonly property real sidebarOuterInset: sidebarOnLeft ? panels.x : win.width - (panels.x + panels.width)

    x: (barOnRight ? clampedThickness : bar.clampedWidth) + win.dragMaskPadding
    y: clampedThickness + win.dragMaskPadding
    width: win.width - bar.clampedWidth - clampedThickness - win.dragMaskPadding * 2
    height: win.height - clampedThickness * 2 - win.dragMaskPadding * 2
    intersection: Intersection.Xor

    R {
        panel: root.panels.dashboard
        y: 0
        height: panel.height * (1 - root.panels.dashboard.offsetScale) + root.borderThickness
    }

    R {
        panel: root.panels.launcher
        y: root.win.height - height
        height: panel.height * (1 - root.panels.launcher.offsetScale) + root.borderThickness
    }

    R {
        id: sessionRegion

        panel: root.panels.sessionWrapper
        x: root.sidebarOnLeft ? 0 : root.win.width - width
        width: panel.width * (1 - root.panels.session.offsetScale) + root.sidebarOuterInset + sidebarRegion.width
    }

    R {
        id: sidebarRegion

        panel: root.panels.sidebar
        x: root.sidebarOnLeft ? 0 : root.win.width - width
        width: panel.width * (1 - root.panels.sidebar.offsetScale) + root.sidebarOuterInset
    }

    R {
        panel: root.panels.osdWrapper
        x: root.sidebarOnLeft ? 0 : root.win.width - width
        width: panel.width * (1 - root.panels.osd.offsetScale) + root.sidebarOuterInset + sessionRegion.width
    }

    R {
        panel: root.panels.notifications
        y: 0
        height: panel.height + root.borderThickness
    }

    R {
        panel: root.panels.utilities
        y: root.win.height - height
        height: panel.height * (1 - root.panels.utilities.offsetScale) + root.borderThickness
    }

    R {
        // Trails the reveal so the mask never covers more than the popout actually shows
        readonly property real revealed: panel.width * (1 - root.panels.popoutsWrapper.offsetScale)

        panel: root.panels.popoutsWrapper
        x: panel.x + root.panels.x + (root.barOnRight ? panel.width - revealed : 0)
        width: revealed
    }

    component R: Region {
        required property Item panel

        x: panel.x + root.panels.x
        y: panel.y + root.borderThickness
        width: panel.width
        height: panel.height
        intersection: Intersection.Subtract
    }
}
