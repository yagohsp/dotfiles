import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null && card.active
    anchor.window: ShellGlobals.primaryBarWindow
    anchor.rect.x: 0
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) - 2
    implicitWidth: ShellGlobals.primaryBarWindow?.width ?? 1920
    implicitHeight: 480 + 28
    color: "transparent"
    grabFocus: false

    readonly property string _active: (ShellGlobals.openPopup !== "" && !(ShellGlobals.openPopup === "volume" && ShellGlobals.volumeModalCentered))
        ? ShellGlobals.openPopup : ""

    readonly property var _activeHover: root._active === "wifi" ? ShellGlobals.wifiHover
        : root._active === "volume" ? ShellGlobals.volumeHover
        : root._active === "backlight" ? ShellGlobals.backlightHover
        : root._active === "bluetooth" ? ShellGlobals.bluetoothHover
        : root._active === "system" ? ShellGlobals.systemHover
        : root._active === "calendar" ? ShellGlobals.calendarHover : null

    readonly property var _contentComponents: ({
        wifi: wifiContent,
        volume: volumeContent,
        backlight: backlightContent,
        bluetooth: bluetoothContent,
        system: systemContent,
        calendar: calendarContent,
    })

    function _bodyWidth(name) {
        if (name === "wifi") return 320
        if (name === "volume") return 360
        if (name === "backlight") return 280
        if (name === "bluetooth") return 300
        if (name === "system") return 228
        if (name === "calendar") return 278
        return 280
    }

    function _targetX(name) {
        const fm = 58
        const bw = root._bodyWidth(name)
        const barW = root.implicitWidth
        if (name === "calendar") return Math.round((barW - (bw + fm * 2)) / 2)
        const centerX = name === "wifi" ? ShellGlobals.wifiButtonCenterX
            : name === "volume" ? ShellGlobals.volumeButtonCenterX
            : name === "backlight" ? ShellGlobals.backlightButtonCenterX
            : name === "bluetooth" ? ShellGlobals.bluetoothButtonCenterX
            : name === "system" ? ShellGlobals.systemButtonCenterX : barW / 2
        return Math.max(8, Math.min(centerX - bw / 2 - fm, barW - (bw + fm * 2) - 8))
    }

    Binding {
        target: ShellGlobals.wifiHover
        property: "suppressClose"
        value: WifiService.connecting
    }

    PopupCard {
        id: card
        open: root._active !== ""
        color: root._active === "wifi" || root._active === "bluetooth" ? Theme.base : Theme.overlay
        borderWidth: 2
        borderColor: Theme.iris
        flareMargin: 58
        targetBodyWidth: root._active !== "" ? root._bodyWidth(root._active) : card.targetBodyWidth
        targetX: root._active !== "" ? root._targetX(root._active) : card.targetX
        content: root._active !== "" ? root._contentComponents[root._active] : null
    }

    CloseOnExit {
        anchors.fill: card
        hover: root._activeHover
    }

    Loader {
        id: _warmup
        visible: false

        readonly property var _queue: [wifiContent, volumeContent, backlightContent, bluetoothContent, systemContent, calendarContent]
        property int _i: 0

        function _loadNext() {
            if (_i >= _queue.length) {
                sourceComponent = null
                return
            }
            sourceComponent = _queue[_i]
            _i++
        }

        onLoaded: Qt.callLater(_loadNext)
        Component.onCompleted: Qt.callLater(_loadNext)
    }

    Component { id: wifiContent; WifiPopupContent {} }
    Component { id: volumeContent; VolumePopupContent {} }
    Component { id: backlightContent; BacklightPopupContent {} }
    Component { id: bluetoothContent; BluetoothPopupContent {} }
    Component { id: systemContent; SystemPopupContent {} }
    Component { id: calendarContent; CalendarPopupContent {} }
}
