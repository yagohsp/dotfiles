import QtQuick
import QtQuick.Shapes

Shape {
    id: root

    property color color: "transparent"
    property real topRadius: 8
    property real bottomRadius: 8
    property real joinSmoothing: 10
    property real bodyWidth: width
    property real borderWidth: 0
    property color borderColor: "transparent"
    property real squircleAmount: 0.85

    preferredRendererType: Shape.CurveRenderer

    function _marginNeeded(r, j) {
        return 2 * Math.sqrt(r * j) - r
    }

    function _buildPath(close) {
        const w = width, h = height
        const bw = (bodyWidth > 0 && bodyWidth < w) ? bodyWidth : w
        const flareActive = bw < w
        const m = (w - bw) / 2
        const br = Math.max(0, Math.min(bottomRadius, h / 2, bw / 2))

        let r = Math.max(0, Math.min(topRadius, h / 2, bw / 2))
        let j = Math.max(0, joinSmoothing)

        if (!flareActive || m < 1) {
            return _plainPath(bw, h, r, br, m)
        }

        const marginNeed = _marginNeeded(r, j)
        const marginScale = marginNeed > 0 ? Math.min(1, m / marginNeed) : 1
        const heightScale = Math.min(1, (h - br) / Math.max(r, j))
        const s = Math.max(0, Math.min(1, marginScale, heightScale))
        r *= s
        j *= s

        const cxLeft = m + r - 2 * Math.sqrt(r * j)
        const cxRight = w - cxLeft
        const hSpan = m - cxLeft
        const sq = Math.max(0, Math.min(1, squircleAmount))
        const vy = r * (1 - sq)
        const hx = sq * hSpan

        const segs = [
            `M ${cxLeft},0`,
            `C ${cxLeft + hx},0 ${m},${vy} ${m},${r}`,
            `L ${m},${h - br}`,
            `A ${br},${br} 0 0,0 ${m + br},${h}`,
            `L ${m + bw - br},${h}`,
            `A ${br},${br} 0 0,0 ${m + bw},${h - br}`,
            `L ${m + bw},${r}`,
            `C ${m + bw},${vy} ${cxRight - hx},0 ${cxRight},0`,
        ]
        if (close) segs.push("Z")
        return segs.join(" ")
    }

    function _plainPath(w, h, r, br, ox) {
        ox = ox || 0
        return [
            `M ${ox + r},0`,
            `L ${ox + w - r},0`,
            `A ${r},${r} 0 0,1 ${ox + w},${r}`,
            `L ${ox + w},${h - br}`,
            `A ${br},${br} 0 0,1 ${ox + w - br},${h}`,
            `L ${ox + br},${h}`,
            `A ${br},${br} 0 0,1 ${ox},${h - br}`,
            `L ${ox},${r}`,
            `A ${r},${r} 0 0,1 ${ox + r},0`,
            "Z",
        ].join(" ")
    }

    ShapePath {
        fillColor: root.color
        strokeColor: "transparent"
        strokeWidth: -1

        PathSvg {
            path: root._buildPath(true)
        }
    }

    ShapePath {
        fillColor: "transparent"
        strokeColor: root.borderColor
        strokeWidth: root.borderWidth > 0 ? root.borderWidth : -1
        joinStyle: ShapePath.RoundJoin
        capStyle: ShapePath.FlatCap

        PathSvg {
            path: root._buildPath(false)
        }
    }
}
