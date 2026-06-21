import QtQuick
import QtQuick.Layouts
import Quickshell

PopupWindow {
    id: root
    visible: ShellGlobals.primaryBarWindow !== null && revealBox.active
    anchor.window: ShellGlobals.primaryBarWindow
    readonly property int bodyWidth: 278
    readonly property int flareMargin: 58
    anchor.rect.x: Math.round(((ShellGlobals.primaryBarWindow?.width ?? 1920) - implicitWidth) / 2)
    anchor.rect.y: (ShellGlobals.primaryBarWindow?.height ?? 44) - 2
    implicitWidth: bodyWidth + flareMargin * 2
    implicitHeight: revealBox.implicitHeight
    color: "transparent"
    grabFocus: false

    property date currentDate: new Date()

    function _firstCellDate() {
        const first = new Date(currentDate.getFullYear(), currentDate.getMonth(), 1)
        let dow = (first.getDay() + 6) % 7
        const start = new Date(first)
        start.setDate(start.getDate() - dow)
        return start
    }

    function _cellDate(index) {
        const start = _firstCellDate()
        const d = new Date(start)
        d.setDate(d.getDate() + index)
        return d
    }

    RevealBox {
        id: revealBox
        open: ShellGlobals.calendarOpen
        color: Theme.overlay
        flareMargin: root.flareMargin
        bodyWidth: root.bodyWidth
        borderWidth: 2
        borderColor: Theme.iris

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Rectangle {
                implicitWidth: prevLbl.implicitWidth + 16; implicitHeight: prevLbl.implicitHeight + 4
                color: prevMa.pressed ? Theme.highlightMed : Theme.highlightLow; radius: 2
                Text { id: prevLbl; anchors.centerIn: parent; text: "‹"; color: Theme.text; font.pixelSize: 16; font.family: Theme.font }
                MouseArea { id: prevMa; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.currentDate = new Date(root.currentDate.getFullYear(), root.currentDate.getMonth() - 1, 1) }
            }

            Text {
                Layout.fillWidth: true; horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDate(root.currentDate, "MMMM yyyy")
                font.family: Theme.font; font.pixelSize: 14; font.bold: true; color: Theme.text
            }

            Rectangle {
                implicitWidth: nextLbl.implicitWidth + 16; implicitHeight: nextLbl.implicitHeight + 4
                color: nextMa.pressed ? Theme.highlightMed : Theme.highlightLow; radius: 2
                Text { id: nextLbl; anchors.centerIn: parent; text: "›"; color: Theme.text; font.pixelSize: 16; font.family: Theme.font }
                MouseArea { id: nextMa; anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.currentDate = new Date(root.currentDate.getFullYear(), root.currentDate.getMonth() + 1, 1) }
            }
        }

        Row {
            spacing: 2
            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                Text {
                    required property string modelData
                    width: 34; height: 20; text: modelData; horizontalAlignment: Text.AlignHCenter
                    font.family: Theme.font; font.pixelSize: 11; font.bold: true; color: Theme.subtle
                }
            }
        }

        Grid {
            columns: 7; spacing: 2

            Repeater {
                model: 42
                Rectangle {
                    required property int index
                    readonly property date cellDate: root._cellDate(index)
                    readonly property bool inMonth: cellDate.getMonth() === root.currentDate.getMonth()
                    readonly property bool isToday: {
                        const t = new Date()
                        return cellDate.getFullYear() === t.getFullYear()
                            && cellDate.getMonth()    === t.getMonth()
                            && cellDate.getDate()     === t.getDate()
                    }
                    width: 34; height: 28; radius: 4
                    color: isToday ? Theme.highlightMed : "transparent"
                    Text {
                        anchors.centerIn: parent; text: parent.cellDate.getDate()
                        font.family: Theme.font; font.pixelSize: 13; font.bold: parent.isToday
                        color: !parent.inMonth ? Theme.muted : Theme.text
                    }
                }
            }
        }
    }

    CloseOnExit {
        anchors.fill: revealBox
        hover: ShellGlobals.calendarHover
    }

    Binding { target: ShellGlobals; property: "calendarActive"; value: revealBox.active }
}
