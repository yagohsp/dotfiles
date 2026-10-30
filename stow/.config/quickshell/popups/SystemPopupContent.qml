import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import ".."

ColumnLayout {
    id: root
    width: parent.width
    spacing: 0

    function _run(args) {
        ShellGlobals.closeNow("system")
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = args
        p.running = true
    }

    SysMenuItem { label: "Restart";           onClicked: root._run(["bash", "-c", "pkill obs; systemctl reboot"]) }
    SysMenuItem { label: "Suspend";           onClicked: root._run(["systemctl", "suspend"]) }
    SysMenuItem { label: "Update & Shutdown"; onClicked: root._run(["bash", Quickshell.env("HOME") + "/.config/quickshell/scripts/update-and-shutdown.sh"]) }
    SysMenuItem { label: "Shutdown";          onClicked: root._run(["bash", "-c", "pkill obs; systemctl poweroff"]) }
}
