//@ pragma DefaultEnv QS_NO_RELOAD_POPUP=1
//@ pragma DefaultEnv QS_DROP_EXPENSIVE_FONTS=1
//@ pragma DefaultEnv QSG_RENDER_LOOP=threaded
//@ pragma DefaultEnv QT_QUICK_FLICKABLE_WHEEL_DECELERATION=10000

import QtQuick
import Quickshell
import Quickshell.Io
import YshellLight.Config
import qs.services
import qs.modules.drawers
import qs.modules.launcher.services

ShellRoot {
    id: root

    settings.watchFiles: true

    FontLoader {
        source: Quickshell.shellPath("assets/google-sans-flex/GoogleSansFlex-VariableFont_GRAD,ROND,opsz,slnt,wdth,wght.ttf")
    }

    Binding {
        target: ShellState
        property: "shellRoot"
        value: root
    }

    Drawers {
        id: drawers
    }

    // Bind from i3 with: quickshell -p ~/.config/yshell ipc call drawers toggle launcher
    IpcHandler {
        target: "drawers"

        function toggle(drawer: string): void {
            const state = drawers.activeState();
            if (!state || !(drawer in state))
                return;
            if (drawer === "launcher")
                state.launcherMode = "";
            state[drawer] = !state[drawer];
        }

        function clipboard(): void {
            const state = drawers.activeState();
            if (!state)
                return;
            if (state.launcher && state.launcherMode === "clipboard") {
                state.launcher = false;
                return;
            }
            ClipboardHistory.reload();
            state.launcherMode = "clipboard";
            state.launcher = true;
        }
    }
}
