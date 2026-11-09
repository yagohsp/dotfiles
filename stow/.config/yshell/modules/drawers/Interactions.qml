import QtQuick
import QtQuick.Controls
import Quickshell
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
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

    // The OSD never opens on hover, but stays open while the pointer is using it
    function setOsdHovered(hovered: bool): void {
        if (panels.osd.hovered && !hovered)
            screenState.osd = false;
        panels.osd.hovered = hovered;
    }

    function inOsd(x: real, y: real): bool {
        const panel = panels.osdWrapper;
        return panels.osd.visible && y >= bar.implicitHeight && x >= panel.x && x <= panel.x + panel.width && y <= bar.implicitHeight + panel.height;
    }

    function inDashboard(x: real, y: real): bool {
        const island = bar.centreIsland;
        if (y < bar.implicitHeight && x >= island.x && x <= island.x + island.width)
            return true;

        const panel = panels.dashboardWrapper;
        return panels.dashboard.visible && x >= panel.x - Config.border.rounding && x <= panel.x + panel.width + Config.border.rounding && y <= bar.implicitHeight + panel.height + Config.border.rounding;
    }

    function trayMenuIsOpen(): bool {
        return popouts.currentName.startsWith("traymenu") && ((popouts.current as StackView)?.depth ?? 0) > 1;
    }

    function closePopouts(): void {
        if (!trayMenuIsOpen() && !AudioRoutes.dragging) {
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

            setOsdHovered(false);
            screenState.dashboard = false;
        }
    }

    onPositionChanged: event => {
        setOsdHovered(inOsd(event.x, event.y));
        screenState.dashboard = inDashboard(event.x, event.y);

        if (event.y < bar.implicitHeight)
            bar.checkPopout(event.x);
        else if (!inTopPanel(panels.popoutsWrapper, event.x, event.y))
            closePopouts();
    }
}
