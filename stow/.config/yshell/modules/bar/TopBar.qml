pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Services.UPower
import Caelestia.Config
import qs.components
import qs.services
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
    readonly property color groupColour: Colours.palette.m3surfaceContainer
    readonly property color pillText: "#241c2a"

    readonly property var monitor: Hypr.monitorFor(screen)
    readonly property var workspaces: Hypr.workspaces.values.filter(w => w.monitor === monitor)
    readonly property int activeIndex: workspaces.findIndex(w => w.number === (monitor?.activeWorkspace?.number ?? -1))
    readonly property var trayItems: SystemTray.items.values.filter(i => i.status !== Status.Passive && !GlobalConfig.bar.tray.hiddenIcons.some(h => i.id === h))

    function closeTray(): void {
    }

    function openPopout(name: string, item: Item): void {
        popouts.currentName = name;
        popouts.currentCenter = item.mapToItem(root, item.width / 2, 0).x;
        popouts.hasCurrent = true;
    }

    function within(item: Item, x: real): bool {
        const left = item.mapToItem(root, 0, 0).x;
        return x >= left && x <= left + item.width;
    }

    function checkPopout(x: real): void {
        for (let i = 0; i < trayRepeater.count; i++) {
            const item = trayRepeater.itemAt(i);
            if (within(item, x) && item.modelData.hasMenu) {
                openPopout(`traymenu${i}`, item);
                return;
            }
        }

        for (let i = 0; i < pillRepeater.count; i++) {
            const item = pillRepeater.itemAt(i);
            if (item.visible && within(item, x) && item.modelData.popout) {
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

            Rectangle {
                readonly property Item target: workspaceRepeater.count, workspaceRepeater.itemAt(root.activeIndex)

                visible: target !== null
                x: (target?.x ?? 0) + workspaceRow.x
                y: 4
                width: target?.width ?? 0
                height: parent.height - 8
                radius: 6
                color: Colours.palette.m3primary

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

                Repeater {
                    id: workspaceRepeater

                    model: root.workspaces

                    MouseArea {
                        id: workspace

                        required property var modelData
                        required property int index
                        readonly property bool active: index === root.activeIndex

                        implicitWidth: Math.max(30, label.implicitWidth + 16)
                        implicitHeight: root.groupHeight - 8
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Hypr.focusWorkspace(modelData.number)

                        StyledText {
                            id: label

                            anchors.centerIn: parent
                            text: Hypr.trimWsName(workspace.modelData.name)
                            color: workspace.active ? Colours.palette.m3onPrimary : Colours.palette.m3onSurface
                            font.bold: workspace.active
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
                spacing: 8

                Repeater {
                    id: trayRepeater

                    model: root.trayItems

                    TrayItem {}
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
                    popout: "battery",
                    colour: "#d9a9e8"
                },
                {
                    id: "network",
                    popout: "network",
                    colour: "#f5a38f"
                },
                {
                    id: "bluetooth",
                    popout: "bluetooth",
                    colour: "#9cc7f0"
                },
                {
                    id: "audio",
                    popout: "audio",
                    colour: "#f7e08c"
                },
                {
                    id: "date",
                    popout: "",
                    colour: "#aedc9b"
                },
                {
                    id: "time",
                    popout: "",
                    colour: "#f7b96c"
                }
            ]

            Rectangle {
                id: pill

                required property var modelData

                visible: modelData.id !== "battery" || UPower.displayDevice.isLaptopBattery
                implicitWidth: pillText.implicitWidth + 20
                implicitHeight: root.groupHeight
                radius: root.groupRadius
                color: modelData.colour

                StyledText {
                    id: pillText

                    anchors.centerIn: parent
                    color: root.pillText
                    font.bold: true
                    font.features: ({
                            tnum: 1
                        }) // Keeps the island edge still as the seconds tick
                    text: {
                        switch (pill.modelData.id) {
                        case "battery":
                            return `BAT ${Math.round(UPower.displayDevice.percentage * 100)}%`;
                        case "network":
                            return Nmcli.activeEthernet ? "ETH" : Nmcli.active ? `NET ${Nmcli.active.strength}%` : "OFF";
                        case "bluetooth":
                            return "BT";
                        case "audio":
                            return Audio.muted ? "MUTE" : `VOL ${Math.round(Audio.volume * 100)}%`;
                        case "date":
                            return Qt.formatDateTime(clock.date, "dd/MM");
                        default:
                            return Qt.formatDateTime(clock.date, "hh:mm:ss");
                        }
                    }
                }
            }
        }
    }
}
