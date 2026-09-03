import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.modules.bar as Bar
import qs.modules.dashboard as Dashboard
import qs.modules.launcher as Launcher
import qs.modules.notifications as Notifications
import qs.modules.osd as Osd
import qs.modules.session as Session
import qs.modules.sidebar as Sidebar
import qs.modules.utilities as Utilities
import qs.modules.bar.popouts as BarPopouts
import qs.modules.utilities.toasts as Toasts

Item {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState
    required property Bar.BarWrapper bar
    required property real borderThickness

    readonly property alias osd: osd
    readonly property alias osdWrapper: osdWrapper
    readonly property alias notifications: notifications
    readonly property alias session: session
    readonly property alias sessionWrapper: sessionWrapper
    readonly property alias launcher: launcher
    readonly property alias dashboard: dashboard
    readonly property alias popouts: popoutsWrapper.content
    readonly property alias popoutsWrapper: popoutsWrapper
    readonly property alias utilities: utilities
    readonly property alias toasts: toasts
    readonly property alias sidebar: sidebar

    // The bar and the sidebar (along with the panels docked to it) can each be
    // pinned to either side of the screen, independently and per monitor
    readonly property bool barOnRight: Config.bar.position === PanelPosition.Right
    readonly property bool sidebarOnLeft: Config.sidebar.position === PanelPosition.Left

    // How far the panels stacked next to the sidebar have to be inset to clear it
    readonly property real sidebarInset: sidebar.width * (1 - sidebar.offsetScale)
    readonly property real sessionInset: sidebarInset + session.width * (1 - session.offsetScale)

    anchors.fill: parent
    anchors.margins: borderThickness
    anchors.leftMargin: barOnRight ? borderThickness : bar.implicitWidth
    anchors.rightMargin: barOnRight ? bar.implicitWidth : borderThickness

    Item {
        id: osdWrapper

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: root.sidebarOnLeft ? parent.left : undefined
        anchors.right: root.sidebarOnLeft ? undefined : parent.right
        anchors.leftMargin: root.sidebarOnLeft ? root.sessionInset : 0
        anchors.rightMargin: root.sidebarOnLeft ? 0 : root.sessionInset
        clip: sidebar.visible || session.visible

        implicitWidth: osd.implicitWidth * (1 - osd.offsetScale)
        implicitHeight: osd.implicitHeight

        Osd.Wrapper {
            id: osd

            screen: root.screen
            screenState: root.screenState
            sidebarOrSessionVisible: sidebar.visible || session.visible

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.sidebarOnLeft ? parent.left : undefined
            anchors.right: root.sidebarOnLeft ? undefined : parent.right
        }
    }

    Notifications.Wrapper {
        id: notifications

        screenState: root.screenState
        sidebarPanel: sidebar
        osdPanel: osdWrapper
        sessionPanel: sessionWrapper
        utilitiesPanel: utilities

        anchors.top: parent.top
        anchors.left: root.sidebarOnLeft ? parent.left : undefined
        anchors.right: root.sidebarOnLeft ? undefined : parent.right
    }

    Item {
        id: sessionWrapper

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: root.sidebarOnLeft ? parent.left : undefined
        anchors.right: root.sidebarOnLeft ? undefined : parent.right
        anchors.leftMargin: root.sidebarOnLeft ? root.sidebarInset : 0
        anchors.rightMargin: root.sidebarOnLeft ? 0 : root.sidebarInset
        clip: sidebar.visible

        implicitWidth: session.implicitWidth * (1 - session.offsetScale)
        implicitHeight: session.implicitHeight

        Session.Wrapper {
            id: session

            screenState: root.screenState
            sidebarVisible: sidebar.visible

            anchors.verticalCenter: parent.verticalCenter
            anchors.left: root.sidebarOnLeft ? parent.left : undefined
            anchors.right: root.sidebarOnLeft ? undefined : parent.right
        }
    }

    Launcher.Wrapper {
        id: launcher

        screen: root.screen
        screenState: root.screenState
        panels: root

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

    Dashboard.Wrapper {
        id: dashboard

        screenState: root.screenState

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
    }

    BarPopouts.ClipWrapper {
        id: popoutsWrapper

        screen: root.screen
        borderThickness: root.borderThickness
    }

    Utilities.Wrapper {
        id: utilities

        screenState: root.screenState
        sidebar: sidebar
        popouts: popoutsWrapper.content

        anchors.bottom: parent.bottom
        anchors.left: root.sidebarOnLeft ? parent.left : undefined
        anchors.right: root.sidebarOnLeft ? undefined : parent.right
    }

    Toasts.Toasts {
        id: toasts

        anchors.bottom: sidebar.visible ? parent.bottom : utilities.top
        anchors.left: root.sidebarOnLeft ? sidebar.right : undefined
        anchors.right: root.sidebarOnLeft ? undefined : sidebar.left
        anchors.margins: Tokens.padding.medium
    }

    Sidebar.Wrapper {
        id: sidebar

        screenState: root.screenState

        anchors.top: notifications.bottom
        anchors.bottom: utilities.top
        anchors.left: root.sidebarOnLeft ? parent.left : undefined
        anchors.right: root.sidebarOnLeft ? undefined : parent.right
        anchors.topMargin: -notifications.anchors.topMargin
    }
}
