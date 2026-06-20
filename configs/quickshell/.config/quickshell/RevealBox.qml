import QtQuick
import QtQuick.Layouts

// Reusable "flows out of the bar" reveal panel. Anchor this to the top of a
// transparent PopupWindow, and bind the window's implicitHeight to this
// component's implicitHeight so the window stays fixed-size — this
// Rectangle's own height grows from 0 up to that full content height when
// `open` is true, and shrinks back to 0 on close. Real window geometry
// never changes, so nothing triggers a native X11 resize (animating that
// directly causes visible flicker — resizes aren't double-buffered the way
// compositor-side clipping is).
//
// Children are laid out in a ColumnLayout inside a Flickable (scrolls past
// maxHeight) and slide with the reveal — pouring out on open, drawing back
// in on close — instead of a flat wipe.
Item {
    id: root

    property bool open: false
    property color color: "transparent"
    // Scaled from implicitHeight (~0.9ms/px) so the reveal travels at a
    // consistent visual speed instead of a fixed time — a tall popup (e.g.
    // Wi-Fi with many networks) covers more pixels than a short one, so a
    // flat duration made it look faster. Clamped so very short/tall content
    // doesn't animate instantly or take too long.
    property int growDuration: Math.max(120, Math.min(400, Math.round(implicitHeight * 0.9)))
    property int contentMargins: 14
    property int maxHeight: 480
    property int spacing: 10
    property real radius: 8
    // caelestia's own blob-merge system (~/shell, Caelestia.Blobs plugin)
    // defaults to a 28px corner radius blended with 32px of smoothing --
    // smoothing slightly *larger* than the radius. Matching that real scale
    // here, not a smaller guess: the blend is scale-invariant (proportions
    // hold at any size) but legibility against antialiasing is not -- a
    // small radius/smoothing pair is too few pixels to read as anything
    // but a plain corner, regardless of the ratio between them.
    property real topRadius: 44
    // How far (in px) the top corners' fillet into the topbar's underside
    // extends -- the "flowing out of the bar" merged-shape look. Keep this
    // within ~10-20% of topRadius -- pushing it much higher (tried 64
    // against a 48 radius) breaks the circular fillet into a diagonal
    // bevel instead of a round curve.
    property real joinSmoothing: 48
    // Extra width on each side, beyond the body's own content width, for
    // the top corners to flare outward into. Without spare canvas width
    // here the blend can only tighten the body's own corner notch, not
    // bulge outward -- there's no paintable area for it to spill into.
    // 0 (default) disables the flare entirely (current behavior for every
    // popup that hasn't opted in yet); when set, the host PopupWindow must
    // be sized bodyWidth + flareMargin*2 wide -- see WifiModal.
    property real flareMargin: 0
    property real bodyWidth: 0 // required when flareMargin > 0
    // < 1 flattens the join vertically (shorter bulge) without changing
    // how wide it flares.
    property real joinHeightScale: 1
    property real borderWidth: 0
    property color borderColor: "transparent"

    default property alias data: contentCol.data

    implicitHeight: Math.min(contentCol.implicitHeight + contentMargins * 2, maxHeight)

    readonly property real _bodyW: flareMargin > 0 ? bodyWidth : width

    JoinedRect {
        anchors.fill: parent
        color: root.color
        topRadius: root.topRadius
        bottomRadius: root.radius
        smoothing: root.joinSmoothing
        bodyWidth: root._bodyW
        heightScale: root.joinHeightScale
        borderWidth: root.borderWidth
        borderColor: root.borderColor
    }

    // Single source of truth for the animation, 0 (closed) to 1 (open).
    // height and the content parallax both derive from this — neither
    // reads the other, which avoids the binding loop a height<->transform
    // cross-reference caused here before (and crashed Quickshell).
    property real _revealProgress: open ? 1 : 0
    Behavior on _revealProgress { NumberAnimation { duration: root.growDuration; easing.type: Easing.OutCubic } }

    // True while open OR still animating shut. The host PopupWindow should
    // bind its own `visible` to this (not directly to its open flag) —
    // otherwise the window vanishes the instant `open` flips false, before
    // the shrink animation ever gets to play.
    readonly property bool active: open || _revealProgress > 0

    anchors { top: parent.top; left: parent.left; right: parent.right }
    height: _revealProgress * implicitHeight
    clip: true

    // clip only hides paint, not hit-testing on this backend — block clicks
    // on not-yet-revealed content during the opening/closing transition.
    enabled: _revealProgress >= 1

    Flickable {
        id: flick
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.topMargin: root.contentMargins
        anchors.bottomMargin: root.contentMargins
        anchors.horizontalCenter: parent.horizontalCenter
        width: root._bodyW - root.contentMargins * 2
        contentHeight: contentCol.implicitHeight
        clip: true

        transform: Translate {
            y: (root._revealProgress - 1) * root.implicitHeight
        }

        ColumnLayout {
            id: contentCol
            width: flick.width
            spacing: root.spacing
        }
    }
}
