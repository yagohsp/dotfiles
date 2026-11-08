import QtQuick
import QtQuick.Controls
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.modules.bar.popouts as BarPopouts

// Trimmed to the ported modules: the bar, its popouts and the launcher.
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
        if (!containsMouse)
            closePopouts();
    }

    onPositionChanged: event => {
        if (event.y < bar.implicitHeight)
            bar.checkPopout(event.x);
        else if (!inTopPanel(panels.popoutsWrapper, event.x, event.y))
            closePopouts();
    }
}
