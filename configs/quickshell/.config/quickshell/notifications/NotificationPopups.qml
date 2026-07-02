import QtQuick
import Quickshell
import ".."

PopupWindow {
    id: root

    readonly property int bodyW: 380
    readonly property int flareM: 58
    readonly property int barW: ShellGlobals.primaryBarWindow?.width ?? 1920
    readonly property int barH: ShellGlobals.primaryBarWindow?.height ?? 44

    // Window is bodyW + one flare wide, anchored flush to the right edge.
    // The card's right flare (also flareM wide) extends beyond the window boundary
    // and gets clipped — same visual as the system popup right-side clip.
    readonly property int windowW: root.bodyW + root.flareM

    visible: ShellGlobals.primaryBarWindow !== null
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: barW - root.windowW
    anchor.rect.y: barH - 2
    implicitWidth: card.active ? root.windowW : 1
    implicitHeight: card.active ? Math.max(card.implicitHeight + 28, 120) : 1
    color: "transparent"
    grabFocus: false

    PopupCard {
        id: card
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
        targetX: 2
        content: notifContent
    }

    Component { id: notifContent; NotificationPopupContent {} }
}
