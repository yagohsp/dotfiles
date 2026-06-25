import QtQuick
import QtQuick.Layouts
import Quickshell
import ".."

ColumnLayout {
    id: root
    width: parent.width
    spacing: 10

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

    function _eventsForMonth(date, events) {
        const ym = `${date.getFullYear()}-${date.getMonth()}-`
        return events.filter(e => e.dateKey.startsWith(ym))
    }

    Loader {
        Layout.fillWidth: true
        sourceComponent: CalendarService.authenticated ? calendarComponent : loginComponent
    }

    Component {
        id: loginComponent

        ColumnLayout {
            width: root.width
            spacing: 10

            property string clientId: ""
            property string clientSecret: ""

            Text {
                Layout.fillWidth: true
                text: "Connect Google Calendar"
                font.family: Theme.font; font.pixelSize: 14; font.bold: true; color: Theme.text
            }

            Text {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Create an OAuth Desktop client at console.cloud.google.com (enable the Calendar API), then paste its ID and secret below."
                font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
            }

            Text {
                Layout.fillWidth: true
                text: "Import client_secret*.json from ~/.config/quickshell"
                font.family: Theme.font; font.pixelSize: 11; font.underline: true
                color: importMa.pressed ? Theme.text : Theme.foam
                MouseArea {
                    id: importMa
                    anchors.fill: parent
                    anchors.margins: -4
                    enabled: !CalendarService.authenticating
                    cursorShape: Qt.PointingHandCursor
                    onClicked: CalendarService.importFromDownloads()
                }
            }

            TextInput {
                id: idInput
                Layout.fillWidth: true
                leftPadding: 6; rightPadding: 6; topPadding: 5; bottomPadding: 5
                font.family: Theme.font; font.pixelSize: 12; color: Theme.text
                enabled: !CalendarService.authenticating
                Rectangle { anchors.fill: parent; z: -1; color: Theme.highlightMed; radius: 4 }
                Text {
                    visible: idInput.text.length === 0
                    anchors.left: parent.left; anchors.leftMargin: 6; anchors.verticalCenter: parent.verticalCenter
                    text: "Client ID"; font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
                }
            }

            TextInput {
                id: secretInput
                Layout.fillWidth: true
                leftPadding: 6; rightPadding: 6; topPadding: 5; bottomPadding: 5
                font.family: Theme.font; font.pixelSize: 12; color: Theme.text
                echoMode: TextInput.Password
                enabled: !CalendarService.authenticating
                Keys.onReturnPressed: CalendarService.login(idInput.text, secretInput.text)
                Rectangle { anchors.fill: parent; z: -1; color: Theme.highlightMed; radius: 4 }
                Text {
                    visible: secretInput.text.length === 0
                    anchors.left: parent.left; anchors.leftMargin: 6; anchors.verticalCenter: parent.verticalCenter
                    text: "Client Secret"; font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: CalendarService.authUrl !== ""
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "Browser didn't open?"
                    font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                }

                Text {
                    text: copyMa.pressed ? "Copied" : "Copy URL"
                    font.family: Theme.font; font.pixelSize: 11; font.underline: true
                    color: Theme.foam
                    MouseArea {
                        id: copyMa
                        anchors.fill: parent
                        anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.clipboardText = CalendarService.authUrl
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: CalendarService.authenticating ? "Waiting for browser approval…" : CalendarService.authError
                    font.family: Theme.font; font.pixelSize: 11
                    color: CalendarService.authenticating ? Theme.subtle : Theme.love
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    implicitWidth: connectLbl.implicitWidth + 16; implicitHeight: connectLbl.implicitHeight + 8
                    radius: 2
                    color: connectMa.pressed ? Theme.highlightMed : Theme.highlightLow
                    opacity: CalendarService.authenticating ? 0.5 : 1
                    Text {
                        id: connectLbl; anchors.centerIn: parent; text: "Connect"
                        font.family: Theme.font; font.pixelSize: 12; color: Theme.foam
                    }
                    MouseArea {
                        id: connectMa
                        anchors.fill: parent
                        enabled: !CalendarService.authenticating
                        cursorShape: Qt.PointingHandCursor
                        onClicked: CalendarService.login(idInput.text, secretInput.text)
                    }
                }
            }
        }
    }

    Component {
        id: calendarComponent

        ColumnLayout {
            width: root.width
            spacing: 10

            property var monthEvents: root._eventsForMonth(root.currentDate, CalendarService.events)

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
                        readonly property var dayEvents: CalendarService.eventsOnDate(cellDate)
                        readonly property bool hasEvents: dayEvents.length > 0
                        readonly property bool hasHoliday: dayEvents.some(e => e.isHoliday)
                        width: 34; height: 28; radius: 4
                        color: isToday ? Theme.highlightMed : "transparent"
                        Text {
                            anchors.centerIn: parent; text: parent.cellDate.getDate()
                            font.family: Theme.font; font.pixelSize: 13; font.bold: parent.isToday
                            color: parent.hasHoliday ? Theme.gold : (!parent.inMonth ? Theme.muted : Theme.text)
                        }
                        Rectangle {
                            visible: parent.hasEvents
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 3
                            width: 4; height: 4; radius: 2
                            color: parent.isToday ? Theme.text : (parent.hasHoliday ? Theme.gold : Theme.iris)
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.highlightMed }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: "This month"
                    font.family: Theme.font; font.pixelSize: 11; font.bold: true; color: Theme.subtle
                }

                Text {
                    text: CalendarService.refreshing ? "Refreshing…" : "Refresh"
                    font.family: Theme.font; font.pixelSize: 11
                    color: Theme.subtle
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -6
                        enabled: !CalendarService.refreshing
                        cursorShape: Qt.PointingHandCursor
                        onClicked: CalendarService.refresh()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: monthEvents.length === 0
                text: "No events this month"
                font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
                horizontalAlignment: Text.AlignHCenter
            }

            Repeater {
                model: monthEvents

                RowLayout {
                    required property var modelData
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: modelData.dateKey.split("-")[2]
                        font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                        horizontalAlignment: Text.AlignRight
                        Layout.minimumWidth: 16
                    }
                    Text {
                        visible: modelData.startTime !== ""
                        text: modelData.startTime
                        font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                        Layout.minimumWidth: 40
                    }
                    Text {
                        text: modelData.title
                        font.family: Theme.font; font.pixelSize: 12
                        color: modelData.isHoliday ? Theme.gold : Theme.text
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.highlightMed }

            property bool showAddForm: false

            Connections {
                target: CalendarService
                function onAddingEventChanged() {
                    if (!CalendarService.addingEvent && CalendarService.addEventError === "") {
                        titleInput.text = ""
                        timeInput.text = ""
                        showAddForm = false
                    }
                }
            }

            Text {
                visible: !showAddForm
                text: "+ Add event"
                font.family: Theme.font; font.pixelSize: 11; font.underline: true
                color: Theme.foam
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: showAddForm = true
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                visible: showAddForm
                spacing: 6

                TextInput {
                    id: titleInput
                    Layout.fillWidth: true
                    leftPadding: 6; rightPadding: 6; topPadding: 5; bottomPadding: 5
                    font.family: Theme.font; font.pixelSize: 12; color: Theme.text
                    enabled: !CalendarService.addingEvent
                    Rectangle { anchors.fill: parent; z: -1; color: Theme.highlightMed; radius: 4 }
                    Text {
                        visible: titleInput.text.length === 0
                        anchors.left: parent.left; anchors.leftMargin: 6; anchors.verticalCenter: parent.verticalCenter
                        text: "Title"; font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6

                    TextInput {
                        id: dateInput
                        Layout.fillWidth: true
                        text: Qt.formatDate(new Date(), "yyyy-MM-dd")
                        leftPadding: 6; rightPadding: 6; topPadding: 5; bottomPadding: 5
                        font.family: Theme.font; font.pixelSize: 12; color: Theme.text
                        enabled: !CalendarService.addingEvent
                        Rectangle { anchors.fill: parent; z: -1; color: Theme.highlightMed; radius: 4 }
                    }

                    TextInput {
                        id: timeInput
                        Layout.fillWidth: true
                        leftPadding: 6; rightPadding: 6; topPadding: 5; bottomPadding: 5
                        font.family: Theme.font; font.pixelSize: 12; color: Theme.text
                        enabled: !CalendarService.addingEvent
                        Keys.onReturnPressed: CalendarService.addEvent(titleInput.text, dateInput.text + " " + timeInput.text, 60)
                        Rectangle { anchors.fill: parent; z: -1; color: Theme.highlightMed; radius: 4 }
                        Text {
                            visible: timeInput.text.length === 0
                            anchors.left: parent.left; anchors.leftMargin: 6; anchors.verticalCenter: parent.verticalCenter
                            text: "HH:MM"; font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        Layout.fillWidth: true
                        text: CalendarService.addingEvent ? "Adding…" : CalendarService.addEventError
                        font.family: Theme.font; font.pixelSize: 11
                        color: CalendarService.addingEvent ? Theme.subtle : Theme.love
                        wrapMode: Text.WordWrap
                    }

                    Rectangle {
                        implicitWidth: addLbl.implicitWidth + 16; implicitHeight: addLbl.implicitHeight + 8
                        radius: 2
                        color: addMa.pressed ? Theme.highlightMed : Theme.highlightLow
                        opacity: CalendarService.addingEvent ? 0.5 : 1
                        Text {
                            id: addLbl; anchors.centerIn: parent; text: "Add"
                            font.family: Theme.font; font.pixelSize: 12; color: Theme.foam
                        }
                        MouseArea {
                            id: addMa
                            anchors.fill: parent
                            enabled: !CalendarService.addingEvent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: CalendarService.addEvent(titleInput.text, dateInput.text + " " + timeInput.text, 60)
                        }
                    }
                }
            }
        }
    }
}
