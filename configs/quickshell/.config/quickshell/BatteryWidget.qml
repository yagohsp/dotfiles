import QtQuick
import QtQuick.Layouts

Item {
    visible: BatteryService.available
    implicitWidth: visible ? row.implicitWidth + 12 : 0
    implicitHeight: 36

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: BatteryService.status === "Charging" ? "" : ""
            font.family: Theme.font
            font.pixelSize: 16
            color: Theme.iris
        }

        Text {
            text: `${BatteryService.percent}%`
            font.family: Theme.font
            font.pixelSize: 15
            color: Theme.subtle
        }
    }
}
