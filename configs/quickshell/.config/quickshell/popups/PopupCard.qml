import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    property bool open: false
    property color color: "transparent"
    property int growDuration: Math.max(150, Math.min(500, Math.round(implicitHeight * 1.125)))
    property int moveDuration: 300
    property int contentMargins: 14
    property int maxHeight: 480
    property real radius: 8
    property real topRadius: 44
    property real joinSmoothing: 48
    property real flareMargin: 58
    property real borderWidth: 0
    property color borderColor: "transparent"

    property real targetBodyWidth: 0
    property real targetX: 0
    property Component content: null
    property int fadeDuration: 150

    implicitHeight: Math.min((sizingLoader.item ? sizingLoader.item.implicitHeight : 0) + contentMargins * 2, maxHeight)

    property real _bodyW: targetBodyWidth
    Behavior on _bodyW {
        enabled: root._revealProgress > 0
        NumberAnimation { duration: root.moveDuration; easing.type: Easing.OutCubic }
    }

    property real _x: targetX
    Behavior on _x {
        enabled: root._revealProgress > 0
        NumberAnimation { duration: root.moveDuration; easing.type: Easing.OutCubic }
    }

    property real _animHeight: implicitHeight
    Behavior on _animHeight {
        enabled: root._revealProgress > 0
        NumberAnimation { duration: root.moveDuration; easing.type: Easing.OutCubic }
    }

    property Component _loadedContent: null
    onContentChanged: {
        if (root._revealProgress > 0) {
            _fadeSwap.restart()
        } else {
            root._loadedContent = root.content
        }
    }

    SequentialAnimation {
        id: _fadeSwap
        NumberAnimation { target: contentLoader; property: "opacity"; to: 0; duration: root.fadeDuration; easing.type: Easing.OutCubic }
        ScriptAction { script: root._loadedContent = root.content }
        NumberAnimation { target: contentLoader; property: "opacity"; to: 1; duration: root.fadeDuration; easing.type: Easing.OutCubic }
    }

    property real _revealProgress: open ? 1 : 0
    Behavior on _revealProgress {
        NumberAnimation {
            duration: root.growDuration
            easing.type: root.open ? Easing.OutCubic : Easing.InCubic
        }
    }

    readonly property bool active: open || _revealProgress > 0

    anchors.top: parent.top
    x: _x
    width: _bodyW + flareMargin * 2
    height: _revealProgress * _animHeight
    clip: true

    enabled: _revealProgress >= 1

    FlareRect {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: root._bodyW
        color: root.color
        topRadius: root.flareMargin > 0 ? 0 : root.topRadius
        bottomRadius: root.radius
        joinSmoothing: root.joinSmoothing
        bodyWidth: width
        borderWidth: root.borderWidth
        borderColor: root.borderColor
    }

    readonly property real _curveHeight: root.topRadius + root.joinSmoothing
    Item {
        width: root.width
        height: Math.min(root.height, root._curveHeight)
        clip: true

        FlareRect {
            width: root.width
            height: root.height
            color: root.color
            topRadius: root.topRadius
            bottomRadius: root.radius
            joinSmoothing: root.joinSmoothing
            bodyWidth: root._bodyW
            borderWidth: root.borderWidth
            borderColor: root.borderColor
        }
    }

    Flickable {
        id: flick
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: root.contentMargins
        anchors.bottomMargin: root.contentMargins
        anchors.horizontalCenter: parent.horizontalCenter
        width: root._bodyW - root.contentMargins * 2
        contentHeight: contentLoader.item ? contentLoader.item.implicitHeight : 0
        clip: true

        Loader {
            id: contentLoader
            width: flick.width
            sourceComponent: root._loadedContent
        }
    }

    Loader {
        id: sizingLoader
        visible: false
        width: flick.width
        sourceComponent: root.content
    }
}
