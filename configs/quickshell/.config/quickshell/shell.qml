import Quickshell
import "."

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    Variants {
        model: Quickshell.screens
        LockScreen {}
    }

    VolumeOsd {}
    StreamVolumeOsd {}

    GlobalPopup {}
    VolumeCenteredPopup {}
}
