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

    Binding {
        target: ShellGlobals
        property: "primaryBarWindow"
        value: root
        when: root.screen?.name === ShellGlobals.primaryMonitor
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 2
        color: Theme.iris
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
            active: root.screen.name === ShellGlobals.primaryMonitor
            anchors.centerIn: parent
            sourceComponent: ClockWidget {}
        }

        // Right — tools
        Row {
            id: toolsRow
            anchors.right:          parent.right
            anchors.rightMargin:    16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12
            CaptureToggle   {}
            VolumeButton    { id: volumeBtn }
            BacklightButton { id: backlightBtn }
            WifiButton      { id: wifiBtn }
            BatteryWidget   {}
            TrayWidget      {}
            SystemButton    { id: systemBtn }
        }
    }

    // Each button's center, in this window's local coordinates, for its
    // popup to anchor under. Plain property reads (row.x/btn.x/btn.width)
    // so QML's binding engine actually re-evaluates when siblings resize —
    // unlike mapToItem(), whose internal ancestor-chain reads aren't tracked.
    // Gated to the primary monitor's bar since popups only ever anchor there,
    // and every screen has its own Bar instance writing the same globals.
    Binding {
        target: ShellGlobals; property: "volumeButtonCenterX"
        value: toolsRow.x + volumeBtn.x + volumeBtn.width / 2
        when: root.screen?.name === ShellGlobals.primaryMonitor
    }
    Binding {
        target: ShellGlobals; property: "backlightButtonCenterX"
        value: toolsRow.x + backlightBtn.x + backlightBtn.width / 2
        when: root.screen?.name === ShellGlobals.primaryMonitor
    }
    Binding {
        target: ShellGlobals; property: "wifiButtonCenterX"
        value: toolsRow.x + wifiBtn.x + wifiBtn.width / 2
        when: root.screen?.name === ShellGlobals.primaryMonitor
    }
    Binding {
        target: ShellGlobals; property: "systemButtonCenterX"
        value: toolsRow.x + systemBtn.x + systemBtn.width / 2
        when: root.screen?.name === ShellGlobals.primaryMonitor
    }
}
