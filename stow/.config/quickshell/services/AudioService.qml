pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

QtObject {
    id: root

    property string _scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/scripts"

    property var outputDevices: []
    property var defaultSinkOptions: []
    property var streamRoutes: []
    property var streamPeaks: ({})
    property int streamPeaksTick: 0

    property string _devicesJson: ""
    property string _sinksJson: ""
    property string _streamsJson: ""

    function streamPeak(index) {
        const _ = root.streamPeaksTick
        const peaks = root.streamPeaks
        if (!peaks)
            return 0
        const key = String(index)
        return peaks[key] !== undefined ? peaks[key] : 0
    }

    function _applyDevices(d) {
        const json = JSON.stringify(d)
        if (json === root._devicesJson)
            return
        root._devicesJson = json
        root.outputDevices = d
    }

    function _applySinks(d) {
        const json = JSON.stringify(d)
        if (json === root._sinksJson)
            return
        root._sinksJson = json
        root.defaultSinkOptions = d
    }

    function _applyStreams(d) {
        const json = JSON.stringify(d)
        if (json === root._streamsJson)
            return
        root._streamsJson = json
        root.streamRoutes = d
    }

    // Buffered updates received while a slider is being dragged
    property var _pendingDevices: null
    property var _pendingSinks: null
    property var _pendingStreams: null

    // Flush buffers the moment the drag ends
    property bool _dragging: ShellGlobals.anySliderDragging
    on_DraggingChanged: {
        if (!_dragging) {
            if (_pendingDevices  !== null) { root._applyDevices(_pendingDevices);  _pendingDevices  = null }
            if (_pendingSinks    !== null) { root._applySinks(_pendingSinks);      _pendingSinks    = null }
            if (_pendingStreams  !== null) { root._applyStreams(_pendingStreams);  _pendingStreams  = null }
        }
    }

    // ── listeners ──────────────────────────────────────────────────────────

    property var _outputDevicesListener: Process {
        command: ["bash", root._scriptsDir + "/listen-output-device-volumes.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                try {
                    const d = JSON.parse(data)
                    if (ShellGlobals.anySliderDragging) root._pendingDevices = d
                    else root._applyDevices(d)
                } catch(_) {}
            }
        }
    }

    property var _defaultSinkListener: Process {
        command: ["bash", root._scriptsDir + "/listen-default-sink-options.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                try {
                    const d = JSON.parse(data)
                    if (ShellGlobals.anySliderDragging) root._pendingSinks = d
                    else root._applySinks(d)
                } catch(_) {}
            }
        }
    }

    property var _streamRoutesListener: Process {
        command: ["bash", root._scriptsDir + "/listen-stream-routes.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                try {
                    const d = JSON.parse(data)
                    if (ShellGlobals.anySliderDragging) root._pendingStreams = d
                    else root._applyStreams(d)
                } catch(_) {}
            }
        }
    }

    property var _streamPeaksListener: Process {
        command: ["bash", root._scriptsDir + "/listen-stream-peaks.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                const line = data.trim()
                if (!line.startsWith("{"))
                    return
                try {
                    root.streamPeaks = JSON.parse(line)
                    root.streamPeaksTick++
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
        _run(["bash", root._scriptsDir + "/set-default-sink.sh", sinkName])
    }

    function setStreamOutput(index, sinkName) {
        _run(["bash", root._scriptsDir + "/set-stream-output.sh", String(index), sinkName])
    }

    function setStreamOutputDefault(index) {
        _run(["bash", root._scriptsDir + "/set-stream-output-default.sh", String(index)])
    }

    function setStreamVolume(index, volume) {
        _run(["bash", root._scriptsDir + "/set-stream-volume.sh", String(index), String(Math.round(volume))])
    }

    function setOutputVolume(sinkName, volume) {
        _run(["bash", "-c", `pactl set-sink-volume ${sinkName} ${Math.round(volume)}%`])
    }

    function toggleOutputMute(sinkName) {
        _run(["bash", "-c", `pactl set-sink-mute ${sinkName} toggle`])
    }

    function toggleStreamMute(index) {
        _run(["bash", root._scriptsDir + "/toggle-stream-mute.sh", String(index)])
    }
}
