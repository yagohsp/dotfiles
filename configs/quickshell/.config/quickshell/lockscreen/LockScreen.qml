import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pam
import ".."

FloatingWindow {
    id: root
    required property var modelData
    screen: modelData
    readonly property bool isPrimary: modelData.name === ShellGlobals.primaryMonitor

    title: "QuickshellLock-" + modelData.name
    visible: ShellGlobals.locked
    fullscreen: true
    color: Theme.base

    function _run(args) {
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = args
        p.running = true
    }

    Timer {
        id: _placeTimer
        interval: 150
        onTriggered: root._run(["i3-msg", `[title="^${root.title}$"] floating enable, move to output "${root.modelData.name}", fullscreen enable, border none`])
    }

    function _activatePrompt() {
        passwordInput.text = ""
        pam.start()
        passwordInput.forceActiveFocus()
        _placeTimer.restart()
    }

    onVisibleChanged: if (visible && root.isPrimary) {
        _activatePrompt()
    }

    onIsPrimaryChanged: if (visible && root.isPrimary) {
        _activatePrompt()
    }

    PamContext {
        id: pam
        config: "i3lock"
        onCompleted: result => {
            if (result === PamResult.Success) {
                ShellGlobals.locked = false
            } else {
                passwordInput.text = ""
                pam.start()
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: root.isPrimary

        Column {
            anchors.centerIn: parent
            spacing: 18

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "🔒"
                font.pixelSize: 48
                color: Theme.iris
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Quickshell.env("USER") ?? ""
                font.family: Theme.font
                font.pixelSize: 18
                color: Theme.text
            }

            Item {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 220
                height: 36

                Rectangle {
                    anchors.fill: parent
                    radius: 6
                    color: Theme.highlightLow
                    border.color: pam.messageIsError ? Theme.love : Theme.highlightMed
                    border.width: 1
                }

                TextInput {
                    id: passwordInput
                    anchors.fill: parent
                    anchors.margins: 8
                    font.family: Theme.font
                    font.pixelSize: 14
                    color: Theme.text
                    echoMode: pam.responseVisible ? TextInput.Normal : TextInput.Password
                    focus: true
                    onAccepted: if (pam.responseRequired) pam.respond(text)
                }
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: pam.message
                font.family: Theme.font
                font.pixelSize: 12
                color: pam.messageIsError ? Theme.love : Theme.subtle
            }
        }
    }
}
