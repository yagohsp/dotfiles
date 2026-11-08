pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.components
import qs.modules.bar.popouts // Need to import this module so the Wrapper type is the same as others

// X11 port: popouts drop down from the top bar instead of sliding out of the left one.
Item {
    id: root

    required property ShellScreen screen
    required property real borderThickness

    readonly property alias content: content
    property real offsetScale: content.hasCurrent ? 0 : 1

    visible: width > 0 && height > 0
    clip: true

    implicitWidth: content.implicitWidth
    implicitHeight: content.implicitHeight * (1 - offsetScale)

    x: {
        const off = content.currentCenter - borderThickness - content.nonAnimWidth / 2;
        const diff = parent.width - Math.floor(off + content.nonAnimWidth);
        if (diff < 0)
            return off + diff;
        return Math.max(off, 0);
    }

    Behavior on offsetScale {
        Anim {}
    }

    Behavior on x {
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

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }
}
