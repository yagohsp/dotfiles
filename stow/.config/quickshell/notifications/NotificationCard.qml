import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

Rectangle {
    id: root

    required property var entry
    property bool sizing: false
    property bool expanded: false
    property bool closing: false

    readonly property int timeoutMs: entry.timeoutMs
    readonly property var visibleActions: {
        const filtered = []
        for (let i = 0; i < root.entry.actions.length; i++) {
            const action = root.entry.actions[i]
            if (action.identifier !== "default")
                filtered.push(action)
        }
        return filtered
    }

    width: parent ? parent.width : 380
    implicitHeight: inner.implicitHeight + 20
    radius: 10
    color: Theme.overlay

    property real contentOpacity: 1
    property real slideOffset: 0
    opacity: root.contentOpacity

    readonly property real slideDistance: Math.max(root.width, root.parent ? root.parent.width : 0, 380)

    readonly property int enterDuration: 440
    readonly property int exitDuration: 340
    readonly property int enterFadeDuration: 400
    readonly property int exitFadeDuration: 300

    transform: Translate { x: root.slideOffset }

    Behavior on implicitHeight { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

    property int _boundId: -1
    property bool _awaitingReveal: false
    property int _timeTick: 0

    readonly property string timeLabel: {
        const _ = root._timeTick
        return root.formatTime(root.entry.shownAt)
    }

    function formatTime(shownAt) {
        const mins = Math.floor((Date.now() - shownAt) / 60000)
        if (mins < 1)
            return "now"
        if (mins < 60)
            return `${mins}m`
        const hrs = Math.floor(mins / 60)
        if (hrs < 24)
            return `${hrs}h`
        return `${Math.floor(hrs / 24)}d`
    }

    function startExpireTimer() {
        if (root.sizing || root.timeoutMs <= 0)
            return
        const elapsed = Date.now() - (root.entry.shownAt ?? Date.now())
        const remaining = Math.max(0, root.timeoutMs - elapsed)
        if (remaining === 0) {
            root.close(true)
            return
        }
        expireTimer.interval = remaining
        expireTimer.start()
    }

    function tryReveal() {
        if (root.sizing || !root._awaitingReveal || root.width < 8)
            return
        root._awaitingReveal = false
        const offset = root.slideDistance
        root.slideOffset = offset
        root.contentOpacity = 0
        slideReveal.from = offset
        fadeReveal.from = 0
        enterAnim.start()
    }

    function bindEntry() {
        if (!root.entry || root._boundId === root.entry.id)
            return
        root._boundId = root.entry.id
        root.closing = false
        root.expanded = false
        root._awaitingReveal = false
        enterAnim.stop()
        exitAnim.stop()
        expireTimer.stop()

        if (root.sizing) {
            root.contentOpacity = 1
            root.slideOffset = 0
            return
        }

        if (NotificationService.shouldAnimate(root.entry.id)) {
            root.contentOpacity = 0
            root.slideOffset = root.slideDistance
            root._awaitingReveal = true
            Qt.callLater(root.tryReveal)
        } else {
            root.contentOpacity = 1
            root.slideOffset = 0
        }

        startExpireTimer()
    }

    Component.onCompleted: bindEntry()
    onEntryChanged: bindEntry()
    onWidthChanged: root.tryReveal()

    NumberAnimation {
        id: slideReveal
        target: root
        property: "slideOffset"
        to: 0
        duration: root.enterDuration
        easing.type: Easing.OutQuint
    }

    NumberAnimation {
        id: fadeReveal
        target: root
        property: "contentOpacity"
        to: 1
        duration: root.enterFadeDuration
        easing.type: Easing.OutCubic
    }

    ParallelAnimation {
        id: enterAnim
        animations: [slideReveal, fadeReveal]
        onStopped: {
            if (!root.sizing && root.slideOffset === 0)
                NotificationService.markEntered(root.entry.id)
        }
    }

    function close(expired) {
        if (root.closing)
            return
        root.closing = true
        root._awaitingReveal = false
        enterAnim.stop()
        expireTimer.stop()
        exitAnim.expired = expired
        exitAnim.start()
    }

    NumberAnimation {
        id: slideOut
        target: root
        property: "slideOffset"
        to: root.slideDistance
        duration: root.exitDuration
        easing.type: Easing.InQuint
    }

    NumberAnimation {
        id: fadeOut
        target: root
        property: "contentOpacity"
        to: 0
        duration: root.exitFadeDuration
        easing.type: Easing.InCubic
    }

    ParallelAnimation {
        id: exitAnim
        property bool expired: false
        animations: [slideOut, fadeOut]
        onStopped: exitAnim.expired ? NotificationService.expire(root.entry)
                                    : NotificationService.dismiss(root.entry)
    }

    Timer {
        id: expireTimer
        onTriggered: root.close(true)
    }

    Timer {
        id: timeTimer
        interval: 30000
        running: !root.closing
        repeat: true
        onTriggered: root._timeTick++
    }

    Connections {
        target: root.entry.notification
        function onClosed() { root.close(false) }
    }

    HoverHandler {
        onHoveredChanged: {
            if (hovered)
                expireTimer.stop()
            else if (root.timeoutMs > 0 && !root.closing)
                startExpireTimer()
        }
    }

    TapHandler {
        onTapped: NotificationService.activate(root.entry)
    }

    Text {
        anchors {
            top: parent.top
            right: parent.right
            topMargin: 6
            rightMargin: 8
        }
        z: 2
        text: "✕"
        font.pixelSize: 11
        color: Theme.muted

        TapHandler {
            onTapped: root.close(false)
        }
    }

    RowLayout {
        id: inner
        anchors {
            fill: parent
            leftMargin: 10
            rightMargin: 22
            topMargin: 10
            bottomMargin: 10
        }
        spacing: 10

        Rectangle {
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.alignment: Qt.AlignTop
            radius: 16
            color: Theme.highlightMed

            Image {
                id: appIcon
                anchors.centerIn: parent
                width: 18
                height: 18
                visible: status === Image.Ready
                source: root.entry.appIcon ? Quickshell.iconPath(root.entry.appIcon) : ""
                fillMode: Image.PreserveAspectFit
                asynchronous: true
            }

            Text {
                anchors.centerIn: parent
                visible: appIcon.status !== Image.Ready
                text: "󰋼"
                font.family: Theme.font
                font.pixelSize: 16
                color: Theme.subtle
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: root.entry.summary || "Notification"
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize
                    font.bold: true
                    color: Theme.text
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                Text {
                    text: "•"
                    font.family: Theme.font
                    font.pixelSize: 11
                    color: Theme.muted
                }

                Text {
                    text: root.timeLabel
                    font.family: Theme.font
                    font.pixelSize: 11
                    color: Theme.muted
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.entry.body.length > 0
                text: root.entry.body
                font.family: Theme.font
                font.pixelSize: 12
                color: Theme.subtle
                wrapMode: root.expanded ? Text.WordWrap : Text.NoWrap
                maximumLineCount: root.expanded ? 8 : 1
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                visible: root.expanded && root.visibleActions.length > 0

                Repeater {
                    model: root.visibleActions

                    Rectangle {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: actionLabel.implicitHeight + 10
                        radius: 6
                        color: Theme.highlightMed

                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: parent.modelData.text
                            font.family: Theme.font
                            font.pixelSize: 11
                            color: Theme.text
                            elide: Text.ElideRight
                            width: parent.width - 12
                            horizontalAlignment: Text.AlignHCenter
                        }

                        TapHandler {
                            onTapped: {
                                parent.modelData.invoke()
                                root.close(false)
                            }
                        }
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignTop
            text: root.expanded ? "󰅃" : "󰅀"
            font.family: Theme.font
            font.pixelSize: 14
            color: Theme.muted

            TapHandler {
                onTapped: root.expanded = !root.expanded
            }
        }
    }
}
