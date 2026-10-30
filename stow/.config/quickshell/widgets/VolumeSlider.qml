import QtQuick
import ".."

Item {
    id: root
    implicitWidth: 60
    implicitHeight: root.peakLevel >= 0 ? 38 : 32

    property real inputValue: 0
    property real value: 0
    // Animate the logical value, not pixel width - otherwise layout/recreate
    // (parent width 0 → real width) looks like the slider scrubbing from 0.
    property real animatedValue: 0
    property real peakLevel: -1
    property bool liveUpdate: true
    property bool _dragging: false
    property bool _animateReady: false

    readonly property real displayPeak:
        root.peakLevel >= 0 ? root.peakLevel * (root.value / 100) : 0

    signal moved(real val)

    function _setValue(v) {
        root.value = v
        root.animatedValue = v
    }

    onInputValueChanged: {
        if (!_dragging)
            root._setValue(inputValue)
    }

    Component.onCompleted: {
        root._setValue(inputValue)
        Qt.callLater(() => { root._animateReady = true })
    }

    Behavior on animatedValue {
        enabled: root._animateReady && !root._dragging
        NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
    }

    Item {
        id: tracks
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        height: root.peakLevel >= 0 ? 14 : 4

        Rectangle {
            id: volumeTrack
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 4
            radius: 2
            color: Theme.highlightMed

            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, root.animatedValue / 100))
                height: parent.height
                radius: 2
                color: Theme.iris
            }
        }

        Rectangle {
            id: peakTrack
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            height: 3
            radius: 1.5
            color: Theme.highlightMed
            visible: root.peakLevel >= 0

            Rectangle {
                width: parent.width * root.displayPeak
                height: parent.height
                radius: 1.5
                color: Theme.gold

                Behavior on width {
                    NumberAnimation { duration: 80; easing.type: Easing.OutCubic }
                }
            }
        }

        Rectangle {
            id: handle
            anchors.verticalCenter: volumeTrack.verticalCenter
            x: Math.max(0, Math.min(tracks.width - width, root.animatedValue / 100 * tracks.width - width / 2))
            width: 12; height: 12; radius: 6
            color: Theme.text
        }
    }

    Timer {
        id: throttle
        interval: 40
        repeat: true
        onTriggered: root.moved(root.value)
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        preventStealing: true
        cursorShape: Qt.PointingHandCursor

        function _calc() {
            return Math.max(0, Math.min(100, mouseX / root.width * 100))
        }

        onPressed: {
            root._dragging = true
            ShellGlobals.anySliderDragging = true
            root._setValue(_calc())
            if (root.liveUpdate) throttle.start()
        }
        onPositionChanged: {
            if (pressed) root._setValue(_calc())
        }
        onReleased: {
            throttle.stop()
            root._setValue(_calc())
            root.moved(root.value)
            root._dragging = false
            ShellGlobals.anySliderDragging = false
        }
    }
}
