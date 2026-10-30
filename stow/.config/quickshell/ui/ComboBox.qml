import QtQuick
import QtQuick.Controls.Basic as Controls
import ".."

Controls.ComboBox {
    id: control

    implicitHeight: 28
    font.family: Theme.font
    font.pixelSize: 12

    background: Rectangle {
        implicitHeight: 28
        radius: 4
        color: control.pressed || control.popup.visible ? Theme.highlightMed : Theme.highlightLow
    }

    contentItem: Text {
        leftPadding: 8
        rightPadding: control.indicator.width + 8
        text: control.displayText
        font: control.font
        color: Theme.text
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    indicator: Text {
        x: control.width - width - 8
        y: control.topPadding + (control.availableHeight - height) / 2
        text: control.popup.visible ? "^" : "v"
        font: control.font
        color: Theme.subtle
    }

    delegate: Controls.ItemDelegate {
        id: delegateItem
        required property var model
        required property int index
        width: control.width
        highlighted: control.highlightedIndex === index

        contentItem: Text {
            text: control.textRole ? delegateItem.model[control.textRole] : delegateItem.model
            font: control.font
            color: control.currentIndex === delegateItem.index ? Theme.foam : Theme.text
            leftPadding: 8
            verticalAlignment: Text.AlignVCenter
        }

        background: Rectangle {
            implicitHeight: 26
            color: delegateItem.highlighted ? Theme.highlightMed : "transparent"
        }
    }

    popup: Controls.Popup {
        // Rendered as a real top-level window rather than an item inside our
        // small fixed-size panel window - otherwise Popup's automatic
        // "stay within window bounds" logic constrains it to our panel's
        // tiny height and flips/clips it instead of opening below the control.
        popupType: Controls.Popup.Window
        parent: control
        y: control.height + 2
        width: control.width
        // No height cap/scrolling: as a top-level window it has the whole
        // screen to expand into, so it just grows to fit every option.
        implicitHeight: contentItem.implicitHeight
        padding: 2

        background: Rectangle {
            color: Theme.overlay
            radius: 4
            border.width: 1
            border.color: Theme.iris
        }

        contentItem: ListView {
            implicitHeight: contentHeight
            interactive: false
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
        }
    }
}
