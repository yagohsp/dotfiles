import QtQuick
import QtQuick.Layouts
import Quickshell

Item {
    implicitWidth: row.implicitWidth + 24
    implicitHeight: row.implicitHeight + 4

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }

    Rectangle {
        anchors.fill: parent
        color: hovered ? Theme.highlightMed : "transparent"
        radius: 2


        property bool hovered: false

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
            anchors.fill: parent
            hoverEnabled: true
            onEntered: parent.hovered = true
            onExited:  parent.hovered = false
            onClicked: ShellGlobals.calendarOpen = !ShellGlobals.calendarOpen
            cursorShape: Qt.PointingHandCursor
        }
    }
}
