import QtQuick
import QtQuick.Layouts
import ".."

ColumnLayout {
    id: root
    width: parent.width
    spacing: 10

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: "CPU"
            font.family: Theme.font; font.pixelSize: 14; font.bold: true
            color: Theme.text
            Layout.fillWidth: true
        }

        Text {
            text: CpuService.available ? `${CpuService.percent}%` : "…"
            font.family: Theme.font; font.pixelSize: 13; font.bold: true
            color: Theme.iris
        }
    }

    Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.highlightMed }

    MonitorProcessList {
        Layout.fillWidth: true
        accentColor: Theme.iris
        processes: CpuService.processes
        metricKey: "cpu"
        killError: CpuService.killError
        onKillPid: pid => CpuService.killProcess(pid)
        onKillPids: pids => CpuService.killProcesses(pids)
    }
}
