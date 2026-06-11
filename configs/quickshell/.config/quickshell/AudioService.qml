pragma Singleton
import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property var outputDevices: []
    property var defaultSinkOptions: []
    property var streamRoutes: []

    // Buffered updates received while a slider is being dragged
    property var _pendingDevices: null
    property var _pendingSinks: null
    property var _pendingStreams: null

    // Flush buffers the moment the drag ends
    property bool _dragging: ShellGlobals.anySliderDragging
    on_DraggingChanged: {
        if (!_dragging) {
            if (_pendingDevices  !== null) { outputDevices      = _pendingDevices;  _pendingDevices  = null }
            if (_pendingSinks    !== null) { defaultSinkOptions = _pendingSinks;    _pendingSinks    = null }
            if (_pendingStreams  !== null) { streamRoutes       = _pendingStreams;  _pendingStreams  = null }
        }
    }

    // ── listeners ──────────────────────────────────────────────────────────

    property var _outputDevicesListener: Process {
        command: ["bash", "/home/yago/.config/quickshell/scripts/listen-output-device-volumes.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                try {
                    const d = JSON.parse(data)
                    if (ShellGlobals.anySliderDragging) root._pendingDevices = d
                    else root.outputDevices = d
                } catch(_) {}
            }
        }
    }

    property var _defaultSinkListener: Process {
        command: ["bash", "/home/yago/.config/quickshell/scripts/listen-default-sink-options.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                try {
                    const d = JSON.parse(data)
                    if (ShellGlobals.anySliderDragging) root._pendingSinks = d
                    else root.defaultSinkOptions = d
                } catch(_) {}
            }
        }
    }

    property var _streamRoutesListener: Process {
        command: ["bash", "/home/yago/.config/quickshell/scripts/listen-stream-routes.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                try {
                    const d = JSON.parse(data)
                    if (ShellGlobals.anySliderDragging) root._pendingStreams = d
                    else root.streamRoutes = d
                } catch(_) {}
            }
        }
    }

    // ── actions ────────────────────────────────────────────────────────────

    function _run(args) {
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = args
        p.running = true
    }

    function setDefaultSink(sinkName) {
        _run(["bash", "/home/yago/.config/quickshell/scripts/set-default-sink.sh", sinkName])
    }

    function setStreamOutput(index, sinkName) {
        _run(["bash", "/home/yago/.config/quickshell/scripts/set-stream-output.sh", String(index), sinkName])
    }

    function setStreamOutputDefault(index) {
        _run(["bash", "/home/yago/.config/quickshell/scripts/set-stream-output-default.sh", String(index)])
    }

    function setStreamVolume(index, volume) {
        _run(["bash", "/home/yago/.config/quickshell/scripts/set-stream-volume.sh", String(index), String(Math.round(volume))])
    }

    function setOutputVolume(sinkName, volume) {
        _run(["bash", "-c", `pactl set-sink-volume ${sinkName} ${Math.round(volume)}%`])
    }

    function toggleOutputMute(sinkName) {
        _run(["bash", "-c", `pactl set-sink-mute ${sinkName} toggle`])
    }

    function toggleStreamMute(index) {
        _run(["bash", "/home/yago/.config/quickshell/scripts/toggle-stream-mute.sh", String(index)])
    }
}
