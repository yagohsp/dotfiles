pragma Singleton

import Quickshell
import Quickshell.Io
import qs.utils

// The theme chosen with dotfiles/scripts/theme-apply, for what the colour scheme does not cover.
Singleton {
    id: root

    readonly property string script: `${Quickshell.env("HOME")}/dotfiles/scripts/theme-apply`
    property string name
    property string workspace: "#d6b4ab"
    property string osd: "#9692ab"
    property var themes: []

    function apply(theme: string): void {
        Quickshell.execDetached([script, theme]);
    }

    FileView {
        path: `${Paths.state}/theme.json`
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const theme = JSON.parse(text());
            root.name = theme.name;
            root.workspace = `#${theme.workspace}`;
            root.osd = `#${theme.osd}`;
        }
    }

    Process {
        command: [root.script, "--list"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: root.themes = JSON.parse(text)
        }
    }
}
