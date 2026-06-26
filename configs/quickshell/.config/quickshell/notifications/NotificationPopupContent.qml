import QtQuick
import ".."

Column {
    id: root
    width: parent.width
    spacing: 8
    clip: true

    property bool sizing: false

    Repeater {
        model: NotificationService.popups
        delegate: NotificationCard {
            required property var modelData
            width: root.width
            sizing: root.sizing
            entry: modelData
        }
    }
}
