pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import YshellLight.Blobs
import YshellLight.Config
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
        // i3 reserves the height of dock windows, which keeps tiled windows clear of the bar.
        // The extra is the gap under it: i3's own gaps vanish with one window (smart_gaps).
        implicitHeight: bar.implicitHeight + 8
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

        // Only the top strip is drawn: there is no border along the sides or the bottom
        readonly property int thickness: 0

        visible: !anchorSettled.running
        color: "transparent"
        anchor.window: anchorWindow
        implicitWidth: root.screen.width
        implicitHeight: root.screen.height
        mask: root.anyDrawerVisible ? fullRegion : frameRegion

        contentItem.Config.screen: root.screen.name
        contentItem.Tokens.screen: root.screen.name

        // How far the side pieces sit past the screen: the further, the less the curve shows
        readonly property int edgeInset: 7

        component EdgeBlob: BlobRect {
            group: blobGroup
            y: bar.fullscreen ? -implicitHeight * 2 : 0
            implicitWidth: 50
            implicitHeight: bar.implicitHeight + 80
        }

        component IslandBlob: BlobRect {
            required property Item island

            group: blobGroup
            x: island.x
            // Starts above the screen so only the bottom corners are rounded
            y: bar.fullscreen ? -island.height - radius * 3 : -radius
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

            x: 0
            y: bar.fullscreen ? 0 : bar.stripHeight + root.shadowPadding
            width: win.width
            height: win.height - y
            intersection: Intersection.Xor

            // Over fullscreen windows the hole covers everything, and Qt reads an empty mask
            // as no mask at all, so one corner pixel always stays in it
            Region {
                intersection: Intersection.Subtract
                x: 0
                y: 0
                width: bar.fullscreen ? 1 : 0
                height: 1
            }

            // The islands are drawn, so they stay out of the click-through hole
            Region {
                intersection: Intersection.Subtract
                x: bar.leftIsland.x - root.shadowPadding
                y: 0
                width: bar.fullscreen ? 0 : bar.leftIsland.width + root.shadowPadding * 2
                height: bar.implicitHeight + root.shadowPadding
            }

            Region {
                intersection: Intersection.Subtract
                x: bar.centreIsland.x - root.shadowPadding
                y: 0
                width: bar.fullscreen ? 0 : bar.centreIsland.width + root.shadowPadding * 2
                height: bar.implicitHeight + root.shadowPadding
            }

            Region {
                intersection: Intersection.Subtract
                x: bar.rightIsland.x - root.shadowPadding
                y: 0
                width: bar.fullscreen ? 0 : bar.rightIsland.width + root.shadowPadding * 2
                height: bar.implicitHeight + root.shadowPadding
            }

            // Reserved at full size while open, so the mask does not change as it slides
            Region {
                intersection: Intersection.Subtract
                x: (win.width - width) / 2
                y: 0
                width: panels.osd.visible ? panels.osd.implicitWidth + root.shadowPadding * 2 : 0
                height: bar.implicitHeight + panels.osd.implicitHeight + root.shadowPadding
            }

            Region {
                intersection: Intersection.Subtract
                x: (win.width - width) / 2
                y: 0
                width: panels.dashboard.visible ? panels.dashboard.implicitWidth + root.shadowPadding * 2 : 0
                height: bar.implicitHeight + panels.dashboard.implicitHeight + root.shadowPadding
            }

            // Stepped so the mask only changes a few times while the stack resizes
            Region {
                readonly property int step: 120

                intersection: Intersection.Subtract
                x: win.width - width
                y: 0
                width: panels.notifications.visible ? panels.notifications.implicitWidth + root.shadowPadding : 0
                height: Math.ceil((bar.implicitHeight + panels.notifications.height + root.shadowPadding) / step) * step
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
                borderLeft: 0
                borderRight: 0
                // The strip goes off the screen over fullscreen windows
                borderTop: bar.fullscreen ? 0 : bar.stripHeight - anchors.margins
                borderBottom: 0
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

            // Off the sides of the screen, so the outer islands curve into its edges
            EdgeBlob {
                x: -width - win.edgeInset
            }

            EdgeBlob {
                x: win.width + win.edgeInset
            }

            // Sits just below the screen so the launcher flares out where it meets the edge,
            // like the islands do under the strip
            BlobRect {
                group: blobGroup
                x: launcherBg.x - 80
                y: win.height
                implicitWidth: launcherBg.width + 160
                implicitHeight: 50
            }

            BlobRect {
                id: launcherBg

                group: blobGroup
                x: panels.launcher.x + win.thickness
                y: panels.launcher.y + bar.implicitHeight
                implicitWidth: panels.launcher.width
                // Runs past the screen edge so only the top corners are rounded
                implicitHeight: panels.launcher.height + radius
                radius: win.contentItem.Tokens.rounding.extraLarge
                deformScale: (0.04 * win.contentItem.Config.appearance.deformScale) / 10000
            }

            BlobRect {
                id: osdBg

                group: blobGroup
                // Grows out of the strip like the popouts and collapses back into it
                readonly property real reach: bar.implicitHeight - bar.stripHeight / 2

                x: panels.osdWrapper.x
                y: bar.stripHeight / 2
                implicitWidth: panels.osdWrapper.width
                implicitHeight: panels.osdWrapper.height + reach * (1 - panels.osd.offsetScale)
                radius: win.contentItem.Tokens.rounding.extraLarge
                deformScale: (0.1 * win.contentItem.Config.appearance.deformScale) / 10000
            }

            BlobRect {
                id: dashboardBg

                // Grows out of the strip like the popouts and collapses back into it
                readonly property real reach: bar.implicitHeight - bar.stripHeight / 2

                group: blobGroup
                x: panels.dashboardWrapper.x
                y: bar.stripHeight / 2
                implicitWidth: panels.dashboardWrapper.width
                implicitHeight: panels.dashboardWrapper.height + reach * (1 - panels.dashboard.offsetScale)
                radius: win.contentItem.Tokens.rounding.extraLarge
                deformScale: (0.04 * win.contentItem.Config.appearance.deformScale) / 10000
            }

            BlobRect {
                id: notifsBg

                // Grows out of the strip like the popouts and collapses back into it
                readonly property real reach: bar.implicitHeight - bar.stripHeight / 2

                group: blobGroup
                x: panels.notifications.x
                y: bar.stripHeight / 2
                implicitWidth: panels.notifications.width + radius
                implicitHeight: panels.notifications.height + reach * Math.min(1, panels.notifications.height / reach)
                radius: win.contentItem.Tokens.rounding.extraLarge
                deformScale: (0.15 * win.contentItem.Config.appearance.deformScale) / 10000
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
                deformScale: (0.04 * win.contentItem.Config.appearance.deformScale) / 10000
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

                dashboard.transform: Matrix4x4 {
                    matrix: dashboardBg.deformMatrix
                }
                osd.transform: Matrix4x4 {
                    matrix: osdBg.deformMatrix
                }
                notifications.transform: Matrix4x4 {
                    matrix: notifsBg.deformMatrix
                }
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

                visible: !fullscreen
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
