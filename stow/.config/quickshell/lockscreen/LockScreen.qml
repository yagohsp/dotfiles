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
    readonly property bool isRealOutput: !modelData.name.startsWith("__")

    title: "QuickshellLock-" + modelData.name
    visible: ShellGlobals.locked && isRealOutput
    fullscreen: true
    color: Theme.base

    function _run(args) {
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = args
        p.running = true
    }

    function _placeOnOutput() {
        _placeTimer.restart()
    }

    function _activatePrompt() {
        if (!promptLoader.item) return
        promptLoader.item.activate()
    }

    Timer {
        id: _placeTimer
        interval: 150
        onTriggered: root._run(["i3-msg", `[title="^${root.title}$"] floating enable, sticky enable, move to output "${root.modelData.name}", fullscreen enable, border none`])
    }

    Timer {
        id: _promptTimer
        interval: 200
        onTriggered: root._activatePrompt()
    }

    Timer {
        id: _refocusTimer
        interval: 400
        running: root.visible && root.isPrimary
        repeat: true
        onTriggered: {
            root._run(["i3-msg", `[title="^${root.title}$"] focus`])
            if (promptLoader.item) promptLoader.item.refocus()
        }
    }

    onVisibleChanged: {
        if (!visible) return
        _placeOnOutput()
        if (root.isPrimary) _promptTimer.restart()
    }

    onIsPrimaryChanged: if (visible && root.isPrimary) _promptTimer.restart()

    MouseArea {
        anchors.fill: parent
        z: 0
        hoverEnabled: true
        acceptedButtons: Qt.AllButtons
        onWheel: wheel => wheel.accepted = true
        onPressed: mouse => {
            if (root.isPrimary) root._activatePrompt()
            mouse.accepted = true
        }
    }

    Loader {
        id: promptLoader
        active: root.isPrimary
        anchors.fill: parent
        z: 1

        sourceComponent: Component {
            Item {
                id: prompt
                anchors.fill: parent

                function activate() {
                    passwordInput.text = ""
                    pam.start()
                    refocus()
                    root._placeOnOutput()
                }

                function refocus() {
                    passwordInput.forceActiveFocus()
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
                            refocus()
                        }
                    }
                }

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
    }
}
