import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    implicitWidth: row.implicitWidth + 24
    implicitHeight: 36

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Rectangle {
        anchors.fill: parent
        color: ma.pressed        ? Theme.highlightMed
             : ma.containsMouse ? Theme.highlightLow
             :                    "transparent"
        radius: 4
        border.color: ma.containsMouse ? Theme.highlightMed : "transparent"
        border.width: 1

        RowLayout {
            id: row
            anchors.centerIn: parent
            spacing: 8

            Text {
                text: Qt.formatTime(clock.date, "HH:mm")
                font.family: Theme.font
                font.pixelSize: 16
                font.bold: true
                color: Theme.text
            }

            Text {
                text: Qt.formatDate(clock.date, "ddd dd MMM")
                font.family: Theme.font
                font.pixelSize: 11
                color: Theme.subtle
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onClicked: ShellGlobals.calendarOpen = !ShellGlobals.calendarOpen
            cursorShape: Qt.PointingHandCursor
        }
    }
}
