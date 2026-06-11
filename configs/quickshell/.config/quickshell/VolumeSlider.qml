import QtQuick

Item {
    id: root
    implicitWidth: 60
    implicitHeight: 32

    property real inputValue: 0
    property real value: 0
    property bool _dragging: false

    signal moved(real val)

    onInputValueChanged: { if (!_dragging) value = inputValue }
    Component.onCompleted: value = inputValue

    // Track
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width; height: 4; radius: 2
        color: Theme.highlightMed

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value / 100))
            height: parent.height; radius: 2
            color: Theme.iris
        }
    }

    // Handle
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: Math.max(0, Math.min(root.width - width, root.value / 100 * root.width - width / 2))
        width: 12; height: 12; radius: 6
        color: Theme.text
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

        function _calc() {
            return Math.max(0, Math.min(100, mouseX / root.width * 100))
        }

        onPressed: {
            root._dragging = true
            ShellGlobals.anySliderDragging = true
            root.value = _calc()
            throttle.start()
        }
        onPositionChanged: {
            if (pressed) root.value = _calc()
        }
        onReleased: {
            throttle.stop()
            root.value = _calc()
            root.moved(root.value)
            root._dragging = false
            ShellGlobals.anySliderDragging = false
        }
    }
}
