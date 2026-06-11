import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: (ShellGlobals.primaryBarWindow?.width ?? 1920) - (menuBox.implicitWidth + 8)
    anchor.rect.y: ShellGlobals.primaryBarWindow?.height ?? 44
    implicitWidth:  ShellGlobals.systemMenuOpen ? menuBox.implicitWidth  : 0
    implicitHeight: ShellGlobals.systemMenuOpen ? menuBox.implicitHeight : 0
    color: "transparent"
    grabFocus: false

    mask: Region {
        width:  ShellGlobals.systemMenuOpen ? root.implicitWidth  : 0
        height: ShellGlobals.systemMenuOpen ? root.implicitHeight : 0
    }

    function _run(args) {
        ShellGlobals.systemMenuOpen = false
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = args
        p.running = true
    }

    Rectangle {
        id: menuBox
        visible: ShellGlobals.systemMenuOpen
        anchors.fill: parent
        implicitWidth:  menuCol.implicitWidth  + 16
        implicitHeight: menuCol.implicitHeight + 16
        color: Theme.overlay

        ColumnLayout {
            id: menuCol
            anchors.centerIn: parent
            spacing: 0

            SysMenuItem { label: "Restart";           onClicked: root._run(["systemctl", "pkill obs && reboot"]) }
            SysMenuItem { label: "Suspend";           onClicked: root._run(["systemctl", "suspend"]) }
            SysMenuItem { label: "Update & Shutdown"; onClicked: root._run(["bash", "pkill obs && /home/yago/.config/quickshell/scripts/update-and-shutdown.sh"]) }
            SysMenuItem { label: "Shutdown";          onClicked: root._run(["systemctl", "pkill obs && poweroff"]) }
        }
    }
}
