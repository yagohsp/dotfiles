import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

    visible: !ShellGlobals.locked

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

    Item {
        anchors.fill: parent
        // Exposed for hover popups - PopupWindow must anchor to this PanelWindow,
        // not item.Window.window (that is a ProxiedWindow Quickshell rejects).
        readonly property var barWindow: root

        WorkspacesWidget {
            monitorName: root.screen.name
            anchors.left:           parent.left
            anchors.leftMargin:     16
            anchors.verticalCenter: parent.verticalCenter
        }

        ClockWidget {
            anchors.centerIn: parent
        }

        Row {
            id: toolsRow
            anchors.right:          parent.right
            anchors.rightMargin:    16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
            CpuButton       { id: cpuBtn }
            MemoryButton    { id: memoryBtn }
            CaptureToggle   { id: captureBtn }
            VolumeButton    { id: volumeBtn }
            BacklightButton { id: backlightBtn }
            WifiButton      { id: wifiBtn }
            BluetoothButton { id: bluetoothBtn }
            BatteryWidget   {}
            TrayWidget      { anchors.verticalCenter: parent.verticalCenter }
            ConfigButton    {}
            SystemButton    { id: systemBtn }
        }
    }
}
