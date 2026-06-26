import QtQuick
import Quickshell
import ".."

PopupWindow {
    id: root

    readonly property int bodyW: 380
    readonly property int barW: ShellGlobals.primaryBarWindow?.width ?? 1920
    readonly property int barH: ShellGlobals.primaryBarWindow?.height ?? 44

    visible: ShellGlobals.primaryBarWindow !== null
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: 0
    anchor.rect.y: barH - 2
    implicitWidth: card.active ? barW : 1
    implicitHeight: card.active ? Math.max(card.implicitHeight + 28, 120) : 1
    color: "transparent"
    grabFocus: false

    function _targetX() {
        const fm = card.flareMargin
        const bw = root.bodyW
        const centerX = ShellGlobals.systemButtonCenterX
        return Math.max(-fm - 2, Math.min(centerX - bw / 2 - fm, barW - bw - fm + 2))
    }

    PopupCard {
        id: card
        open: NotificationService.popups.length > 0
        color: Theme.base
        borderWidth: 2
        borderColor: Theme.iris
        flareMargin: 58
        radius: 12
        topRadius: 44
        joinSmoothing: 48
        contentMargins: 10
        maxHeight: 720
        clipPanel: true
        contentClip: true
        targetBodyWidth: root.bodyW
        targetX: root._targetX()
        content: notifContent
    }

    Component { id: notifContent; NotificationPopupContent {} }
}
