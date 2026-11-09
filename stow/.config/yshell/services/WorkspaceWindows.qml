pragma Singleton

import Quickshell
import Quickshell.Io

// Icons of the windows open on each i3 workspace, updated from i3's event stream.
Singleton {
    id: root

    property var workspaces: []

    Process {
        command: ["python3", Quickshell.shellPath("scripts/workspaces-all.sh")]
        running: true
        stdout: SplitParser {
            onRead: data => {
                try {
                    root.workspaces = JSON.parse(data);
                } catch (e) {}
            }
        }
    }
}
