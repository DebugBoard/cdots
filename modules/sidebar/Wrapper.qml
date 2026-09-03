pragma ComponentBehavior: Bound

import QtQuick
import Caelestia
import Caelestia.Config
import qs.components

Item {
    id: root

    required property ScreenState screenState
    readonly property Props props: Props {}

    readonly property bool shouldBeActive: screenState.sidebar && Config.sidebar.enabled
    readonly property bool onLeft: Config.sidebar.position === PanelPosition.Left
    readonly property real slideOffset: (-implicitWidth - 5) * offsetScale
    property real offsetScale: shouldBeActive ? 0 : 1

    visible: offsetScale < 1
    anchors.leftMargin: onLeft ? slideOffset : 0
    anchors.rightMargin: onLeft ? 0 : slideOffset
    implicitWidth: Tokens.sizes.sidebar.width
    opacity: 1 - offsetScale

    Behavior on offsetScale {
        Anim {}
    }

    Loader {
        id: content

        // Padding faces the middle of the screen; the screen edge side only needs
        // whatever the border does not already provide
        readonly property real innerPadding: Tokens.padding.large
        readonly property real edgePadding: CUtils.clamp(innerPadding - Config.border.thickness, 0, innerPadding)

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: root.onLeft ? parent.left : undefined
        anchors.right: root.onLeft ? undefined : parent.right
        anchors.leftMargin: root.onLeft ? edgePadding : innerPadding
        anchors.rightMargin: root.onLeft ? innerPadding : edgePadding
        anchors.topMargin: edgePadding
        anchors.bottomMargin: 0

        active: root.shouldBeActive || root.visible

        sourceComponent: Content {
            implicitWidth: Tokens.sizes.sidebar.width - content.innerPadding - content.edgePadding
            props: root.props
            screenState: root.screenState
        }
    }
}
