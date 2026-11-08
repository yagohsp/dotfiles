pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

// Single row: icon, thin bar and percentage.
CustomMouseArea {
    id: root

    required property real volume
    required property bool muted

    readonly property real maxVolume: GlobalConfig.services.maxVolume
    readonly property color accent: muted ? Colours.palette.m3outline : Colours.palette.m3secondary

    function onWheel(event: WheelEvent) {
        if (event.angleDelta.y > 0)
            Audio.incrementVolume();
        else if (event.angleDelta.y < 0)
            Audio.decrementVolume();
    }

    function setFromBar(x: real): void {
        const pos = mapToItem(track, x, 0).x;
        Audio.setVolume(Math.max(0, Math.min(1, pos / track.width)) * maxVolume);
    }

    implicitWidth: 220
    implicitHeight: 44
    hoverEnabled: false

    onPressed: event => setFromBar(event.x)
    onPositionChanged: event => {
        if (pressed)
            setFromBar(event.x);
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 10

        MaterialIcon {
            text: Icons.getVolumeIcon(root.volume, root.muted)
            color: root.accent
            font: Tokens.font.icon.medium
        }

        Rectangle {
            id: track

            Layout.fillWidth: true
            implicitHeight: 10
            radius: 5
            color: Colours.palette.m3surfaceContainerHighest

            Rectangle {
                width: parent.width * (root.muted ? 0 : Math.min(1, root.volume / root.maxVolume))
                height: parent.height
                radius: 5
                color: root.accent
            }
        }

        StyledText {
            text: root.muted ? "Muted" : `${Math.round(root.volume * 100)}%`
            color: Colours.palette.m3onSurface
            font.pixelSize: 12
            font.bold: true
        }
    }
}
