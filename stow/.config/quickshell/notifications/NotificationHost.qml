import QtQuick
import Quickshell.Services.Notifications
import ".."

Item {
    id: root
    visible: false
    width: 0
    height: 0

    NotificationServer {
        actionsSupported: true
        imageSupported: true
        bodyHyperlinksSupported: true

        onNotification: notif => {
            notif.tracked = true
            NotificationService.addNotification(notif)
        }
    }
}
