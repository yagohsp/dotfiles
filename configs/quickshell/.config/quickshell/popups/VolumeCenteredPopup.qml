import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import ".."

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active && !ShellGlobals.locked
    anchor.window: ShellGlobals.primaryBarWindow
    readonly property int _w: 480
    anchor.rect.x: ((ShellGlobals.primaryBarWindow?.width ?? 1920) - implicitWidth) / 2
    anchor.rect.y: (Screen.height - implicitHeight) / 2
    implicitWidth: _w
    implicitHeight: revealBox.implicitHeight
    color: "transparent"
    grabFocus: false

    RevealBox {
        id: revealBox
        open: ShellGlobals.openPopup === "volume" && ShellGlobals.volumeModalCentered
        color: Theme.overlay
        bodyWidth: root._w
        maxHeight: 720
        borderWidth: 2
        borderColor: Theme.iris
        closeHover: ShellGlobals.volumeHover

        VolumePopupContent {}
    }
}
