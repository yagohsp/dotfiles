import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.modules.launcher as Launcher
import qs.modules.bar.popouts as BarPopouts

Item {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState
    required property Item bar
    required property real borderThickness

    readonly property alias launcher: launcher

    readonly property alias popouts: popoutsWrapper.content
    readonly property alias popoutsWrapper: popoutsWrapper
    readonly property Item utilities: Item {}

    anchors.fill: parent
    anchors.margins: borderThickness
    anchors.topMargin: bar.implicitHeight

    Launcher.Wrapper {
        id: launcher

        screen: root.screen
        screenState: root.screenState
        panels: root

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
    }

    BarPopouts.ClipWrapper {
        id: popoutsWrapper

        screen: root.screen
        borderThickness: root.borderThickness
    }
}
