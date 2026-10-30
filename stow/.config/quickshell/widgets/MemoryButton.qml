import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    implicitWidth: row.implicitWidth + 40
    implicitHeight: 36
    color: "transparent"
    radius: 4

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Text {
            text: "󰘚"
            font.family: Theme.font
            font.pixelSize: 20
            color: Theme.iris
        }

        Text {
            text: MemoryService.available ? `${MemoryService.percent}%` : "…"
            font.family: Theme.font
            font.pixelSize: 13
            color: Theme.subtle
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor
        onContainsMouseChanged: {
            if (containsMouse)
                ShellGlobals.claimPopupButton(root, "memoryButtonCenterX")
            ShellGlobals.memoryHover.buttonHovered = containsMouse
        }
    }
}
