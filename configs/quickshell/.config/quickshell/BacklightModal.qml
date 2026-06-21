import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active
    anchor.window: ShellGlobals.primaryBarWindow
    readonly property int bodyWidth: 280
    readonly property int flareMargin: 58
    anchor.rect.x: Math.max(8, Math.min(ShellGlobals.backlightButtonCenterX - bodyWidth / 2 - flareMargin, (ShellGlobals.primaryBarWindow?.width ?? 1920) - implicitWidth - 8))
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) - 2
    implicitWidth: bodyWidth + flareMargin * 2
    implicitHeight: revealBox.implicitHeight
    color: "transparent"
    grabFocus: false

    RevealBox {
        id: revealBox
        open: ShellGlobals.backlightModalOpen
        color: Theme.overlay
        flareMargin: root.flareMargin
        bodyWidth: root.bodyWidth
        borderWidth: 2
        borderColor: Theme.iris

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
        hover: ShellGlobals.backlightHover
    }

    Binding { target: ShellGlobals; property: "backlightActive"; value: revealBox.active }
}
