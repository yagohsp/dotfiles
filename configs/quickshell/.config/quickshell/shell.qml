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

    // Modal windows — visibility driven by ShellGlobals
    VolumeModal     {}
    CalendarDropdown {}
    SystemMenu      {}
}
