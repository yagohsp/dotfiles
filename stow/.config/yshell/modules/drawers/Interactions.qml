import QtQuick
import QtQuick.Controls
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.modules.bar.popouts as BarPopouts

// Trimmed to the ported modules: the bar, its popouts, the launcher, the OSD and notifications.
CustomMouseArea {
    id: root

    required property ShellScreen screen
    required property BarPopouts.Wrapper popouts
    required property ScreenState screenState
    required property Panels panels
    required property Item bar
    required property real borderThickness

    function inTopPanel(panel: Item, x: real, y: real): bool {
        const left = borderThickness + panel.x;
        return y < bar.implicitHeight + panel.y + panel.height && x >= left - Config.border.rounding && x <= left + panel.width + Config.border.rounding;
    }

    function inLauncher(x: real, y: real): bool {
        const panel = panels.launcher;
        const left = borderThickness + panel.x;
        const top = bar.implicitHeight + panel.y;
        return x >= left && x <= left + panel.width && y >= top && y <= top + panel.height;
    }

    property bool osdShortcutActive

    function inOsd(x: real, y: real): bool {
        // Opens from the centre island, then stays open over the panel hanging from it
        const island = bar.centreIsland;
        if (y < bar.implicitHeight)
            return x >= island.x && x <= island.x + island.width;

        const panel = panels.osdWrapper;
        return panels.osd.visible && x >= panel.x - Config.border.rounding && x <= panel.x + panel.width + Config.border.rounding && y <= bar.implicitHeight + panel.height + Config.border.rounding;
    }

    function trayMenuIsOpen(): bool {
        return popouts.currentName.startsWith("traymenu") && ((popouts.current as StackView)?.depth ?? 0) > 1;
    }

    function closePopouts(): void {
        if (!trayMenuIsOpen()) {
            popouts.hasCurrent = false;
            bar.closeTray();
        }
    }

    function onWheel(event: WheelEvent): void {
        if (event.y < bar.implicitHeight)
            bar.handleWheel(event.x, event.angleDelta);
    }

    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
    hoverEnabled: true

    // Clicking outside the panels closes the launcher (HyprlandFocusGrab upstream)
    onPressed: event => {
        if (screenState.launcher && !inLauncher(event.x, event.y))
            screenState.launcher = false;
    }

    onContainsMouseChanged: {
        if (!containsMouse) {
            closePopouts();

            // Only hide if not activated by a shortcut or a volume change
            if (!osdShortcutActive) {
                screenState.osd = false;
                panels.osd.hovered = false;
            }
        }
    }

    onPositionChanged: event => {
        const showOsd = inOsd(event.x, event.y);
        if (!osdShortcutActive) {
            screenState.osd = showOsd;
            panels.osd.hovered = showOsd;
        } else if (showOsd) {
            // Hovering takes over from the shortcut
            osdShortcutActive = false;
            panels.osd.hovered = true;
        }

        if (event.y < bar.implicitHeight)
            bar.checkPopout(event.x);
        else if (!inTopPanel(panels.popoutsWrapper, event.x, event.y))
            closePopouts();
    }

    Connections {
        function onOsdChanged(): void {
            root.osdShortcutActive = root.screenState.osd && !root.inOsd(root.mouseX, root.mouseY);
        }

        target: root.screenState
    }
}
