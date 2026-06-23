import QtQuick
import QtQuick.Layouts
import ".."

Item {
    id: root

    property bool open: false
    property color color: "transparent"
    property int growDuration: Math.max(150, Math.min(500, Math.round(implicitHeight * 1.125)))
    property int contentMargins: 14
    property int maxHeight: 480
    property int spacing: 10
    property real radius: 8
    property real topRadius: 44
    property real joinSmoothing: 48
    property real flareMargin: 0
    property real bodyWidth: 0
    property real borderWidth: 0
    property color borderColor: "transparent"
    property var closeHover: null

    default property alias data: contentCol.data

    implicitHeight: Math.min(contentCol.implicitHeight + contentMargins * 2, maxHeight)

    readonly property real _bodyW: flareMargin > 0 ? bodyWidth : width

    property real _revealProgress: open ? 1 : 0
    Behavior on _revealProgress {
        NumberAnimation {
            duration: root.growDuration
            easing.type: root.open ? Easing.OutCubic : Easing.InCubic
        }
    }

    readonly property bool active: open || _revealProgress > 0

    anchors { top: parent.top; left: parent.left; right: parent.right }
    height: _revealProgress * implicitHeight
    clip: true

    enabled: _revealProgress >= 1

    HoverHandler {
        onHoveredChanged: if (root.closeHover) root.closeHover.popupHovered = hovered
    }

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
        contentHeight: contentCol.implicitHeight
        clip: true

        ColumnLayout {
            id: contentCol
            width: flick.width
            spacing: root.spacing
        }
    }
}
