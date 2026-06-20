import QtQuick

// Closes a popup when the cursor leaves its content area. MouseArea already
// has a native `exited` signal on hover-leave; just attach `onExited:` when
// using this.
//
// Temporarily disabled (hoverEnabled: false) so `onExited` never fires —
// keeps every popup's `onExited:` wiring intact for when this is re-enabled.
MouseArea {
    anchors.fill: parent
    hoverEnabled: false
    acceptedButtons: Qt.NoButton
}
