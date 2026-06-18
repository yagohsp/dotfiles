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

    // Transparent full-screen backdrop — catches outside clicks to close popups
    PopupBackdrop {}

    // Modal windows — visibility driven by ShellGlobals
    VolumeModal     {}
    CalendarDropdown {}
    SystemMenu      {}
}
