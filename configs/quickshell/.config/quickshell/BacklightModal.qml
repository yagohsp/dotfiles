import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

PopupWindow {
    id: root
    // Window stays fixed-size and just snaps open/closed — RevealBox does
    // the actual grow/shrink animation as an in-process clip, which avoids
    // the flicker that comes from animating real X11 window geometry.
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: Math.max(8, Math.min(ShellGlobals.backlightButtonCenterX - implicitWidth / 2, (ShellGlobals.primaryBarWindow?.width ?? 1920) - implicitWidth - 8))
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) - 4
    implicitWidth: 280
    implicitHeight: revealBox.implicitHeight
    color: "transparent"
    grabFocus: false

    RevealBox {
        id: revealBox
        open: ShellGlobals.backlightModalOpen
        color: Theme.overlay

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Text {
                text: "󰃟"
                font.family: Theme.font; font.pixelSize: 18
                color: Theme.iris
            }

            VolumeSlider {
                id: brightnessSlider
                Layout.fillWidth: true
                inputValue: BrightnessService.brightness
                onMoved: BrightnessService.setBrightness(value)
            }

            Text {
                text: `${Math.round(brightnessSlider.value)}%`
                font.family: Theme.font; font.pixelSize: 12; color: Theme.subtle
                Layout.minimumWidth: 36
            }
        }
    }

    CloseOnExit {
        anchors.fill: revealBox
        onExited: ShellGlobals.backlightModalOpen = false
    }
}
