import QtQuick

// Rounded rect, narrower than this item's own canvas (bodyWidth < width),
// whose TOP corners smoothly bulge outward to fill the extra canvas width
// when blended with an implied flat plane at y=0 -- mimicking the "flows
// out of the bar" merged-shape look. The flare needs real spare canvas
// width to bulge into: with bodyWidth == width (no margin) the blend can
// only tighten the corner's own notch, not flare outward, since there's no
// paintable area beyond the body's own edge for it to spill into. Bottom
// corners render as plain rounding; the blend only has a visible effect
// within `smoothing` px of y=0, by construction of the shader.
ShaderEffect {
    id: root

    property color color: "transparent"
    // The blend is scale-invariant: doubling topRadius/smoothing/bodyWidth
    // margin together preserves the same proportional curve, just bigger.
    // Too small and the whole fillet is a handful of pixels and disappears
    // into ordinary antialiasing -- the effect needs real size to read.
    property real topRadius: 8
    property real bottomRadius: 8
    property real smoothing: 10
    property real bodyWidth: width
    // < 1 flattens the merge vertically (shorter bulge) without changing
    // how wide it spreads.
    property real heightScale: 1
    property real borderWidth: 0
    property color borderColor: "transparent"

    property real w: width
    property real h: height
    property vector4d radii: Qt.vector4d(topRadius, topRadius, bottomRadius, bottomRadius)

    fragmentShader: "shaders/blobjoin.frag.qsb"
}
