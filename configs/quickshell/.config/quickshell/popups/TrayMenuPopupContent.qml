import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

ColumnLayout {
    id: root
    width: parent.width
    spacing: 2

    QsMenuOpener {
        id: opener
        menu: ShellGlobals.trayMenuItemShown?.menu ?? null
    }

    Repeater {
        model: opener.children

        Item {
            id: rowItem
            required property var modelData
            Layout.fillWidth: true
            implicitHeight: rowItem.modelData.isSeparator ? 9 : (lbl.implicitHeight + 16)

            Rectangle {
                visible: rowItem.modelData.isSeparator
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width
                height: 1
                color: Theme.highlightMed
            }

            Rectangle {
                visible: !rowItem.modelData.isSeparator
                anchors.fill: parent
                radius: 4
                color: hover.hovered && rowItem.modelData.enabled ? Theme.highlightMed : "transparent"

                HoverHandler {
                    id: hover
                    enabled: rowItem.modelData.enabled
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 12
                    anchors.rightMargin: 12
                    spacing: 8

                    Text {
                        visible: rowItem.modelData.buttonType !== QsMenuButtonType.None
                        text: rowItem.modelData.checkState === Qt.Checked ? "✓" : ""
                        font.family: Theme.font
                        font.pixelSize: 12
                        color: Theme.iris
                        Layout.preferredWidth: 14
                    }

                    Text {
                        id: lbl
                        text: rowItem.modelData.text
                        font.family: Theme.font
                        font.pixelSize: 13
                        color: rowItem.modelData.enabled ? Theme.text : Theme.muted
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    enabled: rowItem.modelData.enabled
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        rowItem.modelData.triggered()
                        ShellGlobals.closeNow("tray")
                    }
                }
            }
        }
    }

    Text {
        visible: opener.menu === null
        text: "No options"
        font.family: Theme.font
        font.pixelSize: 12
        color: Theme.muted
        Layout.alignment: Qt.AlignHCenter
    }
}
