import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active
    anchor.window: ShellGlobals.primaryBarWindow
    readonly property int bodyWidth: 228
    readonly property int flareMargin: 58
    anchor.rect.x: Math.max(8, Math.min(ShellGlobals.systemButtonCenterX - bodyWidth / 2 - flareMargin, (ShellGlobals.primaryBarWindow?.width ?? 1920) - implicitWidth - 8))
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) - 2
    implicitWidth: bodyWidth + flareMargin * 2
    implicitHeight: revealBox.implicitHeight
    color: "transparent"
    grabFocus: false

    function _run(args) {
        ShellGlobals.closeNow("system")
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = args
        p.running = true
    }

    RevealBox {
        id: revealBox
        open: ShellGlobals.systemMenuOpen
        color: Theme.overlay
        spacing: 0
        flareMargin: root.flareMargin
        bodyWidth: root.bodyWidth
        borderWidth: 2
        borderColor: Theme.iris

        SysMenuItem { label: "Restart";           onClicked: root._run(["bash", "-c", "pkill obs; systemctl reboot"]) }
        SysMenuItem { label: "Suspend";           onClicked: root._run(["systemctl", "suspend"]) }
        SysMenuItem { label: "Update & Shutdown"; onClicked: root._run(["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/update-and-shutdown.sh"]) }
        SysMenuItem { label: "Shutdown";          onClicked: root._run(["bash", "-c", "pkill obs; systemctl poweroff"]) }
    }

    CloseOnExit {
        anchors.fill: revealBox
        hover: ShellGlobals.systemHover
    }

    Binding { target: ShellGlobals; property: "systemActive"; value: revealBox.active }
}
