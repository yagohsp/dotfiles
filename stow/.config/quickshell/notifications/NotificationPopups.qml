import QtQuick
import Quickshell
import ".."

PopupWindow {
    id: root

    readonly property int bodyW: 380
    readonly property int flareM: 58
    readonly property int barW: ShellGlobals.primaryBarWindow?.width ?? 1920
    readonly property int barH: ShellGlobals.primaryBarWindow?.height ?? 44

    readonly property int windowW: root.bodyW + root.flareM * 2
    readonly property int windowH: card.active ? Math.max(card.implicitHeight + 28, 120) : 1

    visible: ShellGlobals.primaryBarWindow !== null && card.active
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: barW - root.windowW + 2
    anchor.rect.y: barH - 2
    anchor.rect.width: root.windowW
    anchor.rect.height: root.windowH
    width: root.windowW
    height: root.windowH
    implicitWidth: root.windowW
    implicitHeight: root.windowH
    color: "transparent"
    grabFocus: false

    PopupCard {
        id: card
        fillWidth: true
        open: NotificationService.popups.length > 0
        color: Theme.base
        borderWidth: 2
        borderColor: Theme.iris
        flareMargin: root.flareM
        radius: 12
        topRadius: 44
        joinSmoothing: 48
        contentMargins: 10
        maxHeight: 720
        clipPanel: true
        contentClip: true
        targetBodyWidth: root.bodyW
        targetX: 0
        content: notifContent
    }

    Component { id: notifContent; NotificationPopupContent {} }
}
