pragma Singleton

import QtQuick
import Quickshell
import Quickshell.I3

// X11 port: exposes the small part of the Hyprland service the shell uses, on top of i3.
// i3 workspaces are addressed by number, which is what upstream calls the workspace id.
Singleton {
    readonly property var toplevels: ({
            values: []
        })
    readonly property var workspaces: ({
            values: [...I3.workspaces.values].sort((a, b) => a.number - b.number)
        })
    readonly property var monitors: I3.monitors
    readonly property bool usingLua: false
    readonly property var activeToplevel: null
    readonly property var focusedWorkspace: I3.focusedWorkspace
    readonly property var focusedMonitor: I3.focusedMonitor
    readonly property int activeWsId: focusedWorkspace?.number ?? 1
    readonly property var keyboard: null
    readonly property bool capsLock: false
    readonly property bool numLock: false
    readonly property string defaultKbLayout: "??"
    readonly property string kbLayoutFull: ""
    readonly property string kbLayout: "??"
    readonly property var kbMap: new Map()
    readonly property QtObject extras: QtObject {
        readonly property var options: ({})
        readonly property var devices: ({
                keyboards: []
            })

        function batchMessage(messages: var): void {
        }
        function message(message: string): void {
        }
    }
    readonly property var options: extras.options
    readonly property var devices: extras.devices

    signal configReloaded

    function dispatch(request: string): void {
        I3.dispatch(request);
    }

    function focusWorkspace(ws: var): void {
        I3.dispatch(`workspace number ${ws}`);
    }

    function toggleSpecial(name: string): void {
    }

    function monitorFor(screen: var): var {
        // Reads the model so that bindings re-evaluate once i3 has reported its outputs
        return I3.monitors.values.find(m => m.name === screen?.name) ?? null;
    }

    function toplevelsForWs(ws: var, ignored: var): var {
        return [];
    }

    function trimWsName(name: string): string {
        return name.replace(/^\d+:/, "");
    }
}
