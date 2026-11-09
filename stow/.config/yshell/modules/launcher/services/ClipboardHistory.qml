pragma Singleton

import Quickshell
import Quickshell.Io

// Reads the history kept by clipmenud, newest first.
Singleton {
    id: root

    readonly property string dir: `${Quickshell.env("HOME")}/.local/share/clipmenu.6.${Quickshell.env("USER")}`
    property var entries: []

    function reload(): void {
        loader.running = true;
    }

    function query(search: string): var {
        const needle = search.toLowerCase();
        return needle.length > 0 ? entries.filter(e => e.toLowerCase().includes(needle)) : entries;
    }

    function select(entry: string): void {
        Quickshell.execDetached(["bash", Quickshell.shellPath("scripts/clipboard-select.sh"), entry]);
    }

    Process {
        id: loader

        command: ["sh", "-c", `LC_ALL=C sort -rnk 1 "${root.dir}/line_cache" | cut -d' ' -f2- | awk '!seen[$0]++' | head -n 300`]
        stdout: StdioCollector {
            onStreamFinished: root.entries = text.split("\n").filter(e => e.length > 0)
        }
    }
}
