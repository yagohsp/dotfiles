pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import YshellLight.Config
import qs.components
import qs.services
import qs.utils
import qs.modules.bar.components
import qs.modules.bar.popouts as BarPopouts

// X11 port: full-width top bar. Groups sit left, centre and right, like the upstream column
// laid on its side. Icons are text until an icon font is installed.
Item {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState
    required property BarPopouts.Wrapper popouts

    // Thin band across the top that the three islands hang from
    readonly property int stripHeight: 6
    readonly property int islandPadding: 12
    // Left and right islands extend past the screen so only their inner corners are rounded
    readonly property int islandOverhang: 30
    readonly property alias leftIsland: leftIsland
    readonly property alias centreIsland: centreIsland
    readonly property alias rightIsland: rightIsland

    readonly property int groupHeight: 32
    readonly property int groupRadius: 9
    readonly property color groupColour: "transparent"
    readonly property color workspaceColour: "#d6b4ab"
    readonly property color pillText: Colours.palette.m3onSurface

    readonly property var monitor: Hypr.monitorFor(screen)
    readonly property var workspaces: WorkspaceWindows.workspaces.filter(w => w.monitor === screen.name)
    readonly property int activeIndex: workspaces.findIndex(w => w.id === (monitor?.activeWorkspace?.number ?? -1))
    readonly property bool fullscreen: workspaces[activeIndex]?.fullscreen ?? false
    readonly property var trayItems: SystemTray.items.values.filter(i => i.status !== Status.Passive && !GlobalConfig.bar.tray.hiddenIcons.some(h => i.id === h))

    function closeTray(): void {
    }

    function openPopout(name: string, item: Item): void {
        popouts.currentName = name;
        popouts.currentCenter = item.mapToItem(root, item.width / 2, 0).x;
        popouts.hasCurrent = true;
    }

    // Margin is half the row spacing, so the gaps between items belong to their neighbours
    // and the popout moves between them instead of closing and reopening
    function within(item: Item, x: real, margin = 0): bool {
        const left = item.mapToItem(root, 0, 0).x;
        return x >= left - margin && x <= left + item.width + margin;
    }

    function checkPopout(x: real): void {
        for (let i = 0; i < trayRepeater.count; i++) {
            const item = trayRepeater.itemAt(i);
            if (within(item, x, trayRow.spacing / 2) && item.modelData.hasMenu) {
                openPopout(`traymenu${i}`, item);
                return;
            }
        }

        for (let i = 0; i < pillRepeater.count; i++) {
            const item = pillRepeater.itemAt(i);
            if (item.visible && within(item, x, pillGroup.spacing / 2) && item.modelData.popout) {
                openPopout(item.modelData.popout, item);
                return;
            }
        }

        popouts.hasCurrent = false;
    }

    function handleWheel(x: real, angleDelta: point): void {
        if (within(workspaceGroup, x))
            Hypr.dispatch(angleDelta.y > 0 ? "workspace prev_on_output" : "workspace next_on_output");
        else if (within(pillGroup, x))
            angleDelta.y > 0 ? Audio.incrementVolume() : Audio.decrementVolume();
    }

    implicitHeight: 44

    SystemClock {
        id: clock

        precision: SystemClock.Seconds
    }

    component Group: Rectangle {
        implicitHeight: root.groupHeight
        radius: root.groupRadius
        color: root.groupColour
    }

    Item {
        id: leftIsland

        x: -root.islandOverhang
        width: root.islandOverhang + leftRow.x + leftRow.width + root.islandPadding
        height: root.implicitHeight
    }

    Item {
        id: centreIsland

        x: centreGroup.x - root.islandPadding
        width: centreGroup.width + root.islandPadding * 2
        height: root.implicitHeight
    }

    Item {
        id: rightIsland

        x: pillGroup.x - root.islandPadding
        width: pillGroup.width + root.islandPadding + root.islandOverhang
        height: root.implicitHeight
    }

    RowLayout {
        id: leftRow

        anchors.left: parent.left
        anchors.leftMargin: root.islandPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Group {
            id: workspaceGroup

            implicitWidth: workspaceRow.implicitWidth + 8

            // Below the indicator, so it slides over them and none has to change when it arrives
            Repeater {
                model: workspaceRepeater.count

                Rectangle {
                    required property int index
                    readonly property Item target: workspaceRepeater.itemAt(index)

                    x: (target?.x ?? 0) + workspaceRow.x
                    y: 4
                    width: target?.width ?? 0
                    height: parent.height - 8
                    radius: 6
                    color: "transparent"
                    border.width: 2
                    border.color: Qt.darker(root.workspaceColour, root.workspaces[index]?.occupied ? 1.14 : 1.06)
                }
            }

            Rectangle {
                readonly property Item target: workspaceRepeater.count, workspaceRepeater.itemAt(root.activeIndex)

                visible: target !== null
                x: (target?.x ?? 0) + workspaceRow.x
                y: 4
                width: target?.width ?? 0
                height: parent.height - 8
                radius: 6
                color: Qt.darker(root.workspaceColour, 1.14)

                Behavior on x {
                    Anim {}
                }

                Behavior on width {
                    Anim {}
                }
            }

            Row {
                id: workspaceRow

                anchors.centerIn: parent
                spacing: 4

                Repeater {
                    id: workspaceRepeater

                    // Counted, not the list itself: every i3 event brings a new list, and
                    // rebuilding the items would reset the indicator and reload the icons
                    model: root.workspaces.length

                    MouseArea {
                        id: workspace

                        required property int index
                        readonly property var ws: root.workspaces[index] ?? ({})
                        readonly property string iconList: (ws.icons ?? []).join("\n")
                        readonly property int iconCount: ws.icons?.length ?? 0

                        implicitWidth: iconCount > 0 ? Math.max(46, iconCount * 24 + 10) : 32
                        implicitHeight: root.groupHeight - 8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hypr.dispatch(`workspace "${ws.name}"`)

                        Row {
                            anchors.centerIn: parent
                            spacing: 2

                            Repeater {
                                model: workspace.iconList.length > 0 ? workspace.iconList.split("\n") : []

                                Image {
                                    required property string modelData

                                    source: modelData
                                    sourceSize: Qt.size(20, 20)
                                    width: 20
                                    height: 20
                                    smooth: true
                                }
                            }
                        }
                    }
                }
            }
        }

        Group {
            visible: root.trayItems.length > 0
            implicitWidth: trayRow.implicitWidth + 16

            Row {
                id: trayRow

                anchors.centerIn: parent
                spacing: 6

                Repeater {
                    id: trayRepeater

                    model: root.trayItems

                    TrayItem {
                        implicitWidth: 24
                        implicitHeight: 20
                    }
                }
            }
        }
    }

    Group {
        id: centreGroup

        anchors.centerIn: parent
        implicitWidth: clockText.implicitWidth + 24

        StyledText {
            id: clockText

            anchors.centerIn: parent
            text: Qt.formatDateTime(clock.date, "ddd, dd MMM   hh:mm")
            color: Colours.palette.m3onSurface
            font.bold: true
        }
    }

    Row {
        id: pillGroup

        anchors.right: parent.right
        anchors.rightMargin: root.islandPadding
        anchors.verticalCenter: parent.verticalCenter
        spacing: 6

        Repeater {
            id: pillRepeater

            model: [
                {
                    id: "battery",
                    popout: "battery"
                },
                {
                    id: "network",
                    popout: "network"
                },
                {
                    id: "bluetooth",
                    popout: "bluetooth"
                },
                {
                    id: "audio",
                    popout: "audio"
                },
                {
                    id: "system",
                    popout: "system"
                }
            ]

            Item {
                id: pill

                required property var modelData

                visible: {
                    switch (modelData.id) {
                    case "battery":
                        return UPower.displayDevice.isLaptopBattery;
                    case "bluetooth":
                        return Bluetooth.defaultAdapter !== null;
                    default:
                        return true;
                    }
                }
                readonly property string icon: {
                    switch (modelData.id) {
                    case "battery":
                        return Icons.getBatteryIcon(UPower.displayDevice.percentage, UPower.displayDevice.state === UPowerDeviceState.Charging);
                    case "system":
                        return "power_settings_new";
                    case "network":
                        return Nmcli.activeEthernet ? "cable" : Nmcli.active ? Icons.getNetworkIcon(Nmcli.active.strength) : "wifi_off";
                    case "bluetooth":
                        return Bluetooth.defaultAdapter?.enabled ? "bluetooth" : "bluetooth_disabled";
                    default:
                        return Icons.getVolumeIcon(Audio.volume, Audio.muted);
                    }
                }

                implicitWidth: pillContent.implicitWidth + 12
                implicitHeight: root.groupHeight

                Row {
                    id: pillContent

                    anchors.centerIn: parent
                    spacing: 4

                    MaterialIcon {
                        anchors.verticalCenter: parent.verticalCenter
                        text: pill.icon
                        color: root.pillText
                        font: Tokens.font.icon.small
                    }

                    StyledText {
                        anchors.verticalCenter: parent.verticalCenter
                        visible: text.length > 0
                        color: root.pillText
                        font.bold: true
                        text: {
                            switch (pill.modelData.id) {
                            case "battery":
                                return `${Math.round(UPower.displayDevice.percentage * 100)}%`;
                            case "audio":
                                return Audio.muted ? "" : `${Math.round(Audio.volume * 100)}%`;
                            default:
                                return "";
                            }
                        }
                    }
                }
            }
        }
    }
}
