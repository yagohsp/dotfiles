import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active
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
        borderWidth: 2
        borderColor: Theme.iris

        VolumePopupContent {}
    }

    CloseOnExit {
        anchors.fill: revealBox
        hover: ShellGlobals.volumeHover
    }
}
