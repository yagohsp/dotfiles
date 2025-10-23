import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Services.Pipewire
import Quickshell.Io

import "helpers/iconFinder.js" as IconFinder

ColumnLayout {
    id: column
    required property PwNode node
    Layout.fillWidth: true

    Process {
        command: ["bash", "-c", "grep -l '" + node.properties["application.process.binary"] + "' /usr/share/applications/*.desktop | xargs grep '^Icon=' | cut -d'=' -f2 | head -n 1"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                let icon = this.text.trim();
                if (icon === "") {
                    icon = "audio-volume-high-symbolic";
                }
                iconImage.source = `image://icon/${icon}`;
            }
        }
    }

    PwObjectTracker {
        objects: [node]
    }

    RowLayout {
        Layout.fillWidth: true
        Image {
            id: iconImage
            visible: source != ""
            sourceSize.width: 20
            sourceSize.height: 20
        }
        Label {
            Layout.fillWidth: true
            Text {
                elide: Text.ElideRight
                width: parent.width
                text: {
                    const app = node.properties["application.name"] ?? (node.description != "" ? node.description : node.name);
                    const media = node.properties["media.name"];
                    return media != undefined ? `${app} aaaaaaaaaaa - ${media}` : app;
                }
            }
        }
    }

    RowLayout {
        MouseArea {
            Layout.preferredWidth: 20
            Layout.preferredHeight: 20
            onClicked: node.audio.muted = !node.audio.muted
            Image {
                sourceSize.width: 20
                sourceSize.height: 20
                source: {
                    const icon = !node.audio.muted ? "audio-volume-high-symbolic" : "audio-volume-muted-symbolic";
                    return `image://icon/${icon}`;
                }
            }
        }

        Label {
            Layout.preferredWidth: 50
            text: `${Math.floor(node.audio.volume * 100)}%`
        }

        Slider {
            Layout.fillWidth: true
            value: node.audio.volume
            onValueChanged: node.audio.volume = value
        }
    }
}
