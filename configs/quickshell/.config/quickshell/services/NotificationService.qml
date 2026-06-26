pragma Singleton
import QtQuick
import Quickshell.Services.Notifications
import ".."

QtObject {
    id: root

    readonly property int defaultTimeout: 5000
    readonly property int maxPopups: 5
    readonly property int maxHistory: 50

    property list<var> popups: []
    property list<var> history: []
    property var _enteredIds: ({})

    function shouldAnimate(id) {
        return !root._enteredIds[id]
    }

    function markEntered(id) {
        root._enteredIds[id] = true
    }

    function makeEntry(notif) {
        return {
            id: notif.id,
            notification: notif,
            summary: notif.summary,
            body: notif.body,
            appName: notif.appName,
            appIcon: notif.appIcon,
            urgency: notif.urgency,
            actions: notif.actions,
            timeoutMs: root.timeoutFor(notif),
            shownAt: Date.now(),
        }
    }

    function addNotification(notif) {
        const entry = root.makeEntry(notif)
        root.history = [entry, ...root.history.filter(e => e.id !== notif.id)].slice(0, root.maxHistory)
        root.popups = [entry, ...root.popups.filter(e => e.id !== notif.id)].slice(0, root.maxPopups)
    }

    function removePopup(entry) {
        root.popups = root.popups.filter(e => e.id !== entry.id)
    }

    function dismiss(entry) {
        removePopup(entry)
        entry.notification.dismiss()
    }

    function expire(entry) {
        removePopup(entry)
        entry.notification.expire()
    }

    function clearAll() {
        for (const e of root.popups.slice())
            dismiss(e)
    }

    function activate(entry) {
        const notif = entry.notification
        for (let i = 0; i < notif.actions.length; i++) {
            const action = notif.actions[i]
            if (action.identifier === "default") {
                root.removePopup(entry)
                action.invoke()
                return
            }
        }

        const de = notif.desktopEntry
        if (de) {
            const name = de.substring(de.lastIndexOf(".") + 1)
            const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
            p.command = ["i3-msg", `[class="(?i)${name}"] focus`]
        }

        root.dismiss(entry)
    }

    function timeoutFor(notif) {
        if (notif.resident)
            return -1
        if (notif.expireTimeout === 0)
            return -1
        if (notif.expireTimeout > 0)
            return notif.expireTimeout
        if (notif.urgency === NotificationUrgency.Critical)
            return -1
        return root.defaultTimeout
    }
}
