import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    // reserve 32 px at the top of this monitor
    anchors { top: true; left: true; right: true }
    implicitHeight: 44
    exclusionMode: ExclusionMode.Auto
    color: Theme.base

    Component.onCompleted: {
        if (screen?.name === "DP-4") ShellGlobals.primaryBarWindow = root
    }

    // ── layout ───────────────────────────────────────────────────────────
    Item {
        anchors.fill: parent

        // Left — workspaces
        WorkspacesWidget {
            monitorName: root.screen.name
            anchors.left:           parent.left
            anchors.leftMargin:     16
            anchors.verticalCenter: parent.verticalCenter
        }

        // Center — clock (only on primary monitor)
        Loader {
            active: root.screen.name === "DP-4"
            anchors.centerIn: parent
            sourceComponent: ClockWidget {}
        }

        // Right — tools
        Row {
            anchors.right:          parent.right
            anchors.rightMargin:    16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            CaptureToggle {}
            VolumeButton  {}
            TrayWidget    {}
            SystemButton  {}
        }
    }
}
