#version 440

layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;

layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float w;
    float h;
    float bodyWidth; // body (content) width, <= w -- the rest is flare margin
    float smoothing;
    float heightScale; // < 1 flattens the merge vertically without changing its width
    float borderWidth;
    vec4 radii; // topLeft, topRight, bottomRight, bottomLeft
    vec4 color;
    vec4 borderColor;
};

float sdRoundedBox(vec2 p, vec2 halfSize, vec4 r) {
    bool right = p.x > 0.0;
    bool bottom = p.y > 0.0;
    float rad = right ? (bottom ? r.z : r.y) : (bottom ? r.w : r.x);
    vec2 q = abs(p) - halfSize + rad;
    return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - rad;
}

// Circular smooth-min: a true circular fillet of radius k between two SDFs,
// tangent to both surfaces. Deviates from min(a, b) only where both are
// within k of 0.
float smin(float a, float b, float k) {
    return max(k, min(a, b)) - length(max(vec2(k) - vec2(a, b), vec2(0.0)));
}

void main() {
    vec2 size = vec2(w, h);
    vec2 p = qt_TexCoord0 * size;

    // The body is narrower than the canvas (bodyWidth < w) -- the extra
    // width on each side is the "flare" margin, present purely so there's
    // real, paintable area for the top corners to bulge outward into when
    // blended with the plane below, instead of just tightening their own
    // notch (which is all that's possible when canvas width == body width).
    vec2 bodyHalf = vec2(bodyWidth * 0.5, h * 0.5);
    float distBody = sdRoundedBox(p - size * 0.5, bodyHalf, radii);
    // implied flat ceiling at y=0, just above this item. Dividing by
    // heightScale (<1) makes the plane's influence reach a *real* pixel
    // distance smaller than `smoothing` would otherwise imply, without
    // touching distBody -- so the merge flattens vertically while the
    // flare's horizontal spread (driven by bodyWidth vs w) stays the same.
    float distPlane = p.y / heightScale;

    float merged = smin(distPlane, distBody, smoothing);

    float fw = fwidth(merged);
    // Outer edge of the whole merged shape (fill + border together).
    float alpha = 1.0 - smoothstep(-fw, fw, merged);
    // Inner edge, `borderWidth` further INTO the shape -- merged is more
    // *negative* the deeper inside you are, so the threshold has to be
    // -borderWidth, not +borderWidth (which merged practically never
    // reaches, since that's well outside the shape -- this was the bug,
    // it made innerAlpha always ~1 and the border mask always ~0).
    float innerAlpha = 1.0 - smoothstep(-borderWidth - fw, -borderWidth + fw, merged);
    float borderMask = alpha - innerAlpha;

    vec4 fillColor = color * innerAlpha;
    vec4 strokeColor = borderColor * borderMask;
    fragColor = (fillColor + strokeColor) * qt_Opacity;
}
