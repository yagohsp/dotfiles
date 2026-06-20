import Quickshell
import "."

ShellRoot {
    // One bar per monitor
    Variants {
        model: Quickshell.screens
        Bar {}
    }


    // Volume OSD — triggered via FIFO from show-volume-osd.sh
    VolumeOsd {}

    // Stream volume OSD — triggered via FIFO from i3-focused-app-volume (mod+XF86AudioVolume*)
    StreamVolumeOsd {}

    // Outside-click-to-close backdrop disabled for now (X11 stacking-order
    // races with the modals it's meant to sit behind — see PopupBackdrop.qml).
    // Popups still close via their own toggle button.

    // Modal windows — visibility driven by ShellGlobals
    VolumeModal     {}
    BacklightModal  {}
    WifiModal       {}
    CalendarDropdown {}
    SystemMenu      {}
}
