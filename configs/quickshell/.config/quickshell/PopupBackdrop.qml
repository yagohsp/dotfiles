import QtQuick
import QtQuick.Window
import Quickshell

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: 0
    anchor.rect.y: 0
    implicitWidth:  ShellGlobals.primaryBarWindow?.width  ?? 1920
    implicitHeight: Screen.height
    color: "transparent"
    grabFocus: ShellGlobals.anyPopupOpen

    mask: Region {
        width:  ShellGlobals.anyPopupOpen ? root.implicitWidth  : 0
        height: ShellGlobals.anyPopupOpen ? root.implicitHeight : 0
    }

    function closeAll() {
        ShellGlobals.calendarOpen    = false
        ShellGlobals.volumeModalOpen = false
        ShellGlobals.systemMenuOpen  = false
    }

    Keys.onEscapePressed: closeAll()

    MouseArea {
        anchors.fill: parent
        onClicked: root.closeAll()
    }
}
