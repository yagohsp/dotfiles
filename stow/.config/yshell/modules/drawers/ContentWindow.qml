pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Caelestia.Blobs
import Caelestia.Config
import qs.components
import qs.services
import qs.modules.bar

// X11 port of the drawers window. i3 would place a fullscreen PanelWindow in its dock area,
// so the content lives in a PopupWindow (override-redirect) anchored to a bar-sized panel.
//
// On X11 the mask also clips rendering, so it has to cover everything that is drawn. It is
// only changed when a drawer appears or disappears: updating it every frame halves the FPS.
Scope {
    id: root

    required property ShellScreen screen

    readonly property ScreenState screenState: ShellState.forScreen(screen)
    readonly property bool anyDrawerVisible: panels.launcher.visible
    readonly property bool wantsKeyboard: screenState?.launcher ?? false
    readonly property int shadowPadding: 20

    property string previousFocus

    onWantsKeyboardChanged: {
        if (wantsKeyboard) {
            grabFocus.running = true;
        } else if (previousFocus.length > 0) {
            Quickshell.execDetached(["bash", Quickshell.shellPath("scripts/x11-focus.sh"), "release", previousFocus]);
            previousFocus = "";
        }
    }

    Process {
        id: grabFocus

        command: ["bash", Quickshell.shellPath("scripts/x11-focus.sh"), "grab", String(Quickshell.processId), String(root.screen.x), String(root.screen.y), String(root.screen.width), String(root.screen.height)]
        stdout: StdioCollector {
            onStreamFinished: root.previousFocus = text.trim()
        }
    }

    PanelWindow {
        id: anchorWindow

        screen: root.screen
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        focusable: false
        anchors.top: true
        anchors.left: true
        anchors.right: true
        // i3 reserves the height of dock windows, which keeps tiled windows clear of the bar
        implicitHeight: bar.implicitHeight
    }

    // The popup takes its position from the anchor when shown, and i3 only moves the anchor to
    // its output after mapping it. Showing the popup right away stacks every screen at x=0.
    Timer {
        id: anchorSettled

        interval: 500
        running: true
    }

    PopupWindow {
        id: win

        readonly property int thickness: contentItem.Config.border.thickness

        visible: !anchorSettled.running
        color: "transparent"
        anchor.window: anchorWindow
        implicitWidth: root.screen.width
        implicitHeight: root.screen.height
        mask: root.anyDrawerVisible ? fullRegion : frameRegion

        contentItem.Config.screen: root.screen.name
        contentItem.Tokens.screen: root.screen.name

        component IslandBlob: BlobRect {
            required property Item island

            group: blobGroup
            x: island.x
            // Starts above the screen so only the bottom corners are rounded
            y: -radius
            implicitWidth: island.width
            implicitHeight: island.height + radius
            radius: win.contentItem.Tokens.rounding.large
        }

        Region {
            id: fullRegion

            x: 0
            y: 0
            width: win.width
            height: win.height
        }

        Region {
            id: frameRegion

            x: win.thickness + root.shadowPadding
            y: bar.stripHeight + root.shadowPadding
            width: win.width - (win.thickness + root.shadowPadding) * 2
            height: win.height - bar.stripHeight - win.thickness - root.shadowPadding * 2
            intersection: Intersection.Xor

            // The islands are drawn, so they stay out of the click-through hole
            Region {
                intersection: Intersection.Subtract
                x: bar.leftIsland.x - root.shadowPadding
                y: 0
                width: bar.leftIsland.width + root.shadowPadding * 2
                height: bar.implicitHeight + root.shadowPadding
            }

            Region {
                intersection: Intersection.Subtract
                x: bar.centreIsland.x - root.shadowPadding
                y: 0
                width: bar.centreIsland.width + root.shadowPadding * 2
                height: bar.implicitHeight + root.shadowPadding
            }

            Region {
                intersection: Intersection.Subtract
                x: bar.rightIsland.x - root.shadowPadding
                y: 0
                width: bar.rightIsland.width + root.shadowPadding * 2
                height: bar.implicitHeight + root.shadowPadding
            }

            // Popouts move and resize while open, so reserve the whole strip under the bar
            Region {
                intersection: Intersection.Subtract
                x: 0
                y: 0
                width: panels.popoutsWrapper.visible ? win.width : 0
                height: bar.implicitHeight + 700
            }
        }

        Item {
            anchors.fill: parent
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 15
                shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
            }

            BlobGroup {
                id: blobGroup

                color: Colours.tPalette.m3surface
                smoothing: win.contentItem.Config.border.smoothing
            }

            BlobInvertedRect {
                anchors.fill: parent
                anchors.margins: -50 // Make border thicker to smooth out bulge from closed drawers
                group: blobGroup
                radius: win.contentItem.Config.border.rounding
                borderLeft: win.thickness - anchors.margins
                borderRight: win.thickness - anchors.margins
                borderTop: bar.stripHeight - anchors.margins
                borderBottom: win.thickness - anchors.margins
            }

            IslandBlob {
                island: bar.leftIsland
            }

            IslandBlob {
                island: bar.centreIsland
            }

            IslandBlob {
                island: bar.rightIsland
            }

            BlobRect {
                id: launcherBg

                group: blobGroup
                x: panels.launcher.x + win.thickness
                y: panels.launcher.y + bar.implicitHeight
                implicitWidth: panels.launcher.width
                implicitHeight: panels.launcher.height
                radius: win.contentItem.Tokens.rounding.extraLarge
                deformScale: (0.1 * win.contentItem.Config.appearance.deformScale) / 10000
            }

            BlobRect {
                id: popoutBg

                // Grows out of the strip, so it stays attached across the gaps between islands
                // and collapses into the strip when closed
                readonly property real reach: bar.implicitHeight - bar.stripHeight / 2

                group: blobGroup
                x: panels.popoutsWrapper.x + win.thickness
                y: bar.stripHeight / 2
                implicitWidth: panels.popoutsWrapper.width
                implicitHeight: panels.popoutsWrapper.height + reach * (1 - panels.popoutsWrapper.offsetScale)
                radius: win.contentItem.Tokens.rounding.extraLarge
                deformScale: ((panels.popouts.hasCurrent ? 0.15 : 0.1) * win.contentItem.Config.appearance.deformScale) / 10000
            }
        }

        Interactions {
            screen: root.screen
            popouts: panels.popouts
            screenState: root.screenState
            panels: panels
            bar: bar
            borderThickness: win.thickness

            Panels {
                id: panels

                screen: root.screen
                screenState: root.screenState
                bar: bar
                borderThickness: win.thickness

                launcher.transform: Matrix4x4 {
                    matrix: launcherBg.deformMatrix
                }
                popouts.transform: Matrix4x4 {
                    matrix: popoutBg.deformMatrix
                }
            }

            TopBar {
                id: bar

                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right

                screen: root.screen
                screenState: root.screenState
                popouts: panels.popouts
            }
        }
    }

    ShellState.ComponentRef {
        screen: root.screen
        slot: "rootWindow"
        component: win
    }

    ShellState.ComponentRef {
        screen: root.screen
        slot: "panels"
        component: panels
    }
}
