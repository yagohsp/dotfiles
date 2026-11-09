pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import qs.services

Scope {
    id: root

    // CX11_SCREENS limits the shell to a comma-separated list of outputs, for development.
    readonly property var allowed: (Quickshell.env("CX11_SCREENS") ?? "").split(",").filter(s => s.length > 0)
    readonly property var screens: Screens.screens.filter(s => allowed.length === 0 || allowed.includes(s.name))

    function activeState(): var {
        if (allowed.length > 0)
            return ShellState.forScreen(screens[0]);
        // i3's focused output is unknown until its first focus event, so right after startup
        // the workspace listener is the reliable source
        const output = WorkspaceWindows.workspaces.find(w => w.active)?.monitor;
        const screen = screens.find(s => s.name === output);
        return screen ? ShellState.forScreen(screen) : ShellState.forActive();
    }

    Variants {
        model: root.screens

        ContentWindow {
            required property ShellScreen modelData

            screen: modelData
        }
    }
}
