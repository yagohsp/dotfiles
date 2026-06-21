import Quickshell
import "."

ShellRoot {
    Variants {
        model: Quickshell.screens
        Bar {}
    }

    VolumeOsd {}
    StreamVolumeOsd {}

    GlobalPopup {}
    VolumeCenteredPopup {}
}
