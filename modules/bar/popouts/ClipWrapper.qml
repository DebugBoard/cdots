pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.modules.bar.popouts // Need to import this module so the Wrapper type is the same as others

Item {
    id: root

    required property ShellScreen screen
    required property real borderThickness

    readonly property alias content: content
    readonly property bool onRight: Config.bar.position === PanelPosition.Right
    property real offsetScale: detachProgress > 0 || content.hasCurrent ? 0 : 1

    // Lerped rather than animating x directly, as the resting x tracks the animating
    // width when attached to a right side bar (which would fight a Behavior on x)
    property real detachProgress: content.isDetached ? 1 : 0
    readonly property real restingX: onRight ? parent.width - width : 0
    readonly property real detachedX: (parent.width - content.nonAnimWidth) / 2

    visible: width > 0 && height > 0
    clip: true

    implicitWidth: content.implicitWidth * (1 - offsetScale)
    implicitHeight: content.implicitHeight

    x: restingX + (detachedX - restingX) * detachProgress
    y: {
        if (content.isDetached)
            return (parent.height - content.nonAnimHeight) / 2;

        const off = content.currentCenter - borderThickness - content.nonAnimHeight / 2;
        const diff = parent.height - Math.floor(off + content.nonAnimHeight);
        if (diff < 0)
            return off + diff;
        return Math.max(off, 0);
    }

    Behavior on offsetScale {
        Anim {}
    }

    Behavior on detachProgress {
        Anim {
            duration: content.animLength
            easing: content.animCurve
        }
    }

    Behavior on y {
        enabled: root.offsetScale < 1

        Anim {
            duration: content.animLength
            easing: content.animCurve
        }
    }

    Wrapper {
        id: content

        screen: root.screen
        offsetScale: root.offsetScale

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: root.onRight ? undefined : parent.left
        anchors.right: root.onRight ? parent.right : undefined
        anchors.leftMargin: root.onRight ? 0 : (-implicitWidth - 5) * root.offsetScale
        anchors.rightMargin: root.onRight ? (-implicitWidth - 5) * root.offsetScale : 0
    }
}
