import QtQuick

// Unstyled stand-in for the M3Shapes module: every shape is a circle.
Rectangle {
    enum Shape {
        Arch,
        Arrow,
        Circle,
        ClamShell,
        Clover4Leaf,
        Cookie12Sided,
        Cookie4Sided,
        Cookie6Sided,
        Cookie7Sided,
        Cookie9Sided,
        Diamond,
        Fan,
        Gem,
        Ghostish,
        Oval,
        Pentagon,
        Pill,
        SemiCircle,
        Slanted,
        SoftBurst,
        Square,
        Sunny,
        Triangle,
        VerySunny
    }

    property int shape
    property real implicitSize
    property var animationEasing
    property int animationDuration

    // Morphing is not drawn, but LoadingIndicator drives these
    property int fromShape
    property int toShape
    property real morphProgress

    function beginBatchUpdate(): void {
    }

    function endBatchUpdate(): void {
    }

    implicitWidth: implicitSize
    implicitHeight: implicitSize
    radius: Math.min(width, height) / 2
}
