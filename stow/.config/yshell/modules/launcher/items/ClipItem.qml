import QtQuick
import YshellLight.Config
import qs.components
import qs.services
import qs.modules.launcher.services

Item {
    id: root

    required property string modelData
    required property var list

    function onClicked(): void {
        ClipboardHistory.select(modelData);
        list.screenState.launcher = false;
    }

    implicitHeight: Tokens.sizes.launcher.itemHeight

    anchors.left: parent?.left
    anchors.right: parent?.right

    StateLayer {
        radius: Tokens.rounding.large
        onClicked: root.onClicked()
    }

    MaterialIcon {
        id: icon

        anchors.left: parent.left
        anchors.leftMargin: Tokens.padding.medium
        anchors.verticalCenter: parent.verticalCenter
        text: "content_paste"
        color: Colours.palette.m3onSurfaceVariant
        font: Tokens.font.icon.medium
    }

    StyledText {
        anchors.left: icon.right
        anchors.leftMargin: Tokens.spacing.medium
        anchors.right: parent.right
        anchors.rightMargin: Tokens.padding.medium
        anchors.verticalCenter: parent.verticalCenter
        text: root.modelData
        textFormat: Text.PlainText
        elide: Text.ElideRight
        maximumLineCount: 1
        font: Tokens.font.body.medium
    }
}
