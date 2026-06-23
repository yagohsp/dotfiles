import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

Item {
    implicitWidth: row.implicitWidth + 24
    implicitHeight: 36

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 4

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
            cursorShape: Qt.ArrowCursor
            onContainsMouseChanged: ShellGlobals.calendarHover.buttonHovered = containsMouse
        }
    }
}
