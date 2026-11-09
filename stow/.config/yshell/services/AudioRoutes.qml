pragma Singleton

import Quickshell
import Quickshell.Io

// Output devices, default sink and per-app audio routing, fed by the pactl listeners in scripts/audio.
Singleton {
    id: root

    readonly property string scripts: Quickshell.shellPath("scripts/audio")

    property var outputDevices: []
    property var defaultSinkOptions: []
    property var streamRoutes: []
    property var streamPeaks: ({})

    // Sliders would jump back if a listener update landed mid-drag, so those wait until it ends
    property bool dragging
    property var pending: ({})

    // Peaks are the only costly listener, so they run only while something shows them
    property int peakWatchers: 0

    function apply(name: string, value: var): void {
        if (JSON.stringify(root[name]) !== JSON.stringify(value))
            root[name] = value;
    }

    function receive(name: string, line: string): void {
        try {
            const value = JSON.parse(line);
            if (dragging)
                pending[name] = value;
            else
                apply(name, value);
        } catch (e) {}
    }

    function streamPeak(index: int): real {
        return streamPeaks[String(index)] ?? 0;
    }

    function run(script: string, ...args): void {
        Quickshell.execDetached(["bash", `${scripts}/${script}`, ...args.map(String)]);
    }

    function setDefaultSink(sink: string): void {
        run("set-default-sink.sh", sink);
    }

    function setOutputVolume(sink: string, volume: real): void {
        Quickshell.execDetached(["pactl", "set-sink-volume", sink, `${Math.round(volume)}%`]);
    }

    function toggleOutputMute(sink: string): void {
        Quickshell.execDetached(["pactl", "set-sink-mute", sink, "toggle"]);
    }

    function setStreamVolume(index: int, volume: real): void {
        run("set-stream-volume.sh", index, Math.round(volume));
    }

    function toggleStreamMute(index: int): void {
        run("toggle-stream-mute.sh", index);
    }

    function setStreamOutput(index: int, sink: string): void {
        run("set-stream-output.sh", index, sink);
    }

    function setStreamOutputDefault(index: int): void {
        run("set-stream-output-default.sh", index);
    }

    onDraggingChanged: {
        if (dragging)
            return;
        for (const name of Object.keys(pending))
            apply(name, pending[name]);
        pending = {};
    }

    Process {
        command: ["bash", `${root.scripts}/listen-output-device-volumes.sh`]
        running: true
        stdout: SplitParser {
            onRead: data => root.receive("outputDevices", data)
        }
    }

    Process {
        command: ["bash", `${root.scripts}/listen-default-sink-options.sh`]
        running: true
        stdout: SplitParser {
            onRead: data => root.receive("defaultSinkOptions", data)
        }
    }

    Process {
        command: ["bash", `${root.scripts}/listen-stream-routes.sh`]
        running: true
        stdout: SplitParser {
            onRead: data => root.receive("streamRoutes", data)
        }
    }

    Process {
        command: ["bash", `${root.scripts}/listen-stream-peaks.sh`]
        running: root.peakWatchers > 0
        stdout: SplitParser {
            onRead: data => {
                if (data.startsWith("{"))
                    root.streamPeaks = JSON.parse(data);
            }
        }
    }
}
