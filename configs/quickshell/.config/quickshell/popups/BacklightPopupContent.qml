import QtQuick
import QtQuick.Layouts
import ".."

ColumnLayout {
    width: parent.width
    spacing: 10

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
