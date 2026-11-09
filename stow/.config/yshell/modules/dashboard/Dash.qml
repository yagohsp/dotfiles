import "dash"
import QtQuick
import QtQuick.Layouts
import YshellLight.Config
import qs.components
import qs.services

RowLayout {
    id: root

    required property ScreenState screenState

    spacing: Tokens.spacing.medium

    Rect {
        Layout.preferredWidth: dateTime.implicitWidth
        Layout.fillHeight: true

        radius: Tokens.rounding.large

        DateTime {
            id: dateTime
        }
    }

    Rect {
        Layout.preferredWidth: 320
        Layout.preferredHeight: 340

        radius: Tokens.rounding.extraLarge

        Calendar {
            anchors.verticalCenter: parent.verticalCenter
            screenState: root.screenState
        }
    }

    Rect {
        Layout.preferredWidth: resources.implicitWidth
        Layout.fillHeight: true

        radius: Tokens.rounding.large

        Resources {
            id: resources
        }
    }

    Rect {
        Layout.preferredWidth: media.implicitWidth
        Layout.fillHeight: true

        radius: Tokens.rounding.extraLarge * 2

        Media {
            id: media
        }
    }

    component Rect: StyledRect {
        color: Colours.tPalette.m3surfaceContainer
    }
}
