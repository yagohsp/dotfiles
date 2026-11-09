pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import YshellLight.Config
import qs.components
import qs.services

// Power actions, same commands as the bar's old system menu.
ColumnLayout {
    id: root

    required property PopoutState popouts

    function run(command: list<string>): void {
        popouts.hasCurrent = false;
        Quickshell.execDetached(command);
    }

    width: 220
    spacing: 2

    Entry {
        label: "Reiniciar"
        icon: "restart_alt"
        onClicked: root.run(["bash", "-c", "pkill obs; systemctl reboot"])
    }

    Entry {
        label: "Suspender"
        icon: "bedtime"
        onClicked: root.run(["systemctl", "suspend"])
    }

    Entry {
        label: "Atualizar e desligar"
        icon: "system_update_alt"
        onClicked: root.run(["bash", Quickshell.shellPath("scripts/update-and-shutdown.sh")])
    }

    Entry {
        label: "Desligar"
        icon: "power_settings_new"
        onClicked: root.run(["bash", "-c", "pkill obs; systemctl poweroff"])
    }

    component Entry: Rectangle {
        id: entry

        required property string label
        required property string icon

        signal clicked

        Layout.fillWidth: true
        implicitHeight: 38
        radius: 8
        color: area.pressed ? Colours.palette.m3surfaceContainerHighest : area.containsMouse ? Colours.palette.m3surfaceContainerHigh : "transparent"

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10

            MaterialIcon {
                anchors.verticalCenter: parent.verticalCenter
                text: entry.icon
                color: Colours.palette.m3onSurface
                font: Tokens.font.icon.medium
            }

            StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: entry.label
                color: Colours.palette.m3onSurface
            }
        }

        MouseArea {
            id: area

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: entry.clicked()
        }
    }
}
