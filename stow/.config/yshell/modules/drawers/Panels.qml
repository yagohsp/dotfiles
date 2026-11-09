import QtQuick
import Quickshell
import Caelestia.Config
import qs.components
import qs.modules.dashboard as Dashboard
import qs.modules.launcher as Launcher
import qs.modules.notifications as Notifications
import qs.modules.osd as Osd
import qs.modules.bar.popouts as BarPopouts

Item {
    id: root

    required property ShellScreen screen
    required property ScreenState screenState
    required property Item bar
    required property real borderThickness

    readonly property alias launcher: launcher
    readonly property alias dashboard: dashboard
    readonly property alias dashboardWrapper: dashboardWrapper
    readonly property alias osd: osd
    readonly property alias osdWrapper: osdWrapper
    readonly property alias notifications: notifications

    readonly property alias popouts: popoutsWrapper.content
    readonly property alias popoutsWrapper: popoutsWrapper
    readonly property Item utilities: Item {}

    anchors.fill: parent
    anchors.margins: borderThickness
    anchors.topMargin: bar.implicitHeight

    Item {
        id: osdWrapper

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        clip: true

        implicitWidth: osd.implicitWidth
        implicitHeight: osd.implicitHeight * (1 - osd.offsetScale)

        Osd.Wrapper {
            id: osd

            screen: root.screen
            screenState: root.screenState
            sidebarOrSessionVisible: false

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }
    }

    Notifications.Wrapper {
        id: notifications

        screenState: root.screenState
        sidebarPanel: Item {}
        osdPanel: osdWrapper
        sessionPanel: Item {}
        utilitiesPanel: root.utilities

        anchors.top: parent.top
        anchors.right: parent.right
    }

    Item {
        id: dashboardWrapper

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        clip: true

        implicitWidth: dashboard.implicitWidth
        implicitHeight: dashboard.implicitHeight * (1 - dashboard.offsetScale)

        Dashboard.Wrapper {
            id: dashboard

            screenState: root.screenState

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
        }
    }

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
