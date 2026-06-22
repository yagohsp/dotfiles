import QtQuick
import QtQuick.Window
import Quickshell
import ".."

PopupWindow {
    id: root
    // Only ever mapped while a popup is actually open. PopupWindow has no
    // X11-specific backend (just the generic Qt popup window type), which
    // implicitly grabs mouse input the moment it's mapped, independent of
    // `mask`/`grabFocus`. Staying permanently mapped from startup (even with
    // a 0x0 mask) was leaving an implicit grab held the whole time, which is
    // what blocked clicks everywhere until a real popup open/close cycle
    // released it. Not existing as a mapped window when idle removes the
    // mechanism entirely instead of trying to keep its state at zero.
    visible: ShellGlobals.primaryBarWindow !== null && ShellGlobals.anyPopupOpen
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
        ShellGlobals.calendarOpen       = false
        ShellGlobals.volumeModalOpen    = false
        ShellGlobals.systemMenuOpen     = false
        ShellGlobals.backlightModalOpen = false
        ShellGlobals.wifiModalOpen      = false
    }

    Keys.onEscapePressed: closeAll()

    MouseArea {
        anchors.fill: parent
        onClicked: root.closeAll()
    }
}
