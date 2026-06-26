import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    id: root
    required property var modelData
    screen: modelData

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

        WorkspacesWidget {
            monitorName: root.screen.name
            anchors.left:           parent.left
            anchors.leftMargin:     16
            anchors.verticalCenter: parent.verticalCenter
        }

        Loader {
            active: root.screen.name === ShellGlobals.primaryMonitor
            anchors.centerIn: parent
            sourceComponent: ClockWidget {}
        }

        Row {
            id: toolsRow
            anchors.right:          parent.right
            anchors.rightMargin:    16
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0
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

    Binding {
        target: ShellGlobals; property: "captureButtonCenterX"
        value: toolsRow.x + captureBtn.x + captureBtn.width / 2
        when: root.screen?.name === ShellGlobals.primaryMonitor
    }
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
        target: ShellGlobals; property: "bluetoothButtonCenterX"
        value: toolsRow.x + bluetoothBtn.x + bluetoothBtn.width / 2
        when: root.screen?.name === ShellGlobals.primaryMonitor
    }
    Binding {
        target: ShellGlobals; property: "systemButtonCenterX"
        value: toolsRow.x + systemBtn.x + systemBtn.width / 2
        when: root.screen?.name === ShellGlobals.primaryMonitor
    }
}
