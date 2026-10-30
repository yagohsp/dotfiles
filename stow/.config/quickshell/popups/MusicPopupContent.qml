import QtQuick
import QtQuick.Layouts
import ".."

ColumnLayout {
    id: root
    width: parent.width
    spacing: 10

    property string activeTab: "search"
    readonly property int bodyHeight: 660

    implicitHeight: MusicService.authenticated ? bodyHeight : loginComponentImplicitHeight
    property int loginComponentImplicitHeight: 120

    Loader {
        Layout.fillWidth: true
        Layout.preferredHeight: implicitHeight
        sourceComponent: MusicService.authenticated ? libraryComponent : loginComponent
    }

    Component {
        id: loginComponent

        ColumnLayout {
            width: root.width
            spacing: 10

            Text {
                Layout.fillWidth: true
                text: "YouTube Music"
                font.family: Theme.font; font.pixelSize: 14; font.bold: true; color: Theme.text
            }

            Text {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: "Connects to your existing Chrome YouTube Music session."
                font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: MusicService.authenticating ? "Connecting…" : MusicService.authError
                    font.family: Theme.font; font.pixelSize: 11
                    color: MusicService.authenticating ? Theme.subtle : Theme.love
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    implicitWidth: connectLbl.implicitWidth + 16; implicitHeight: connectLbl.implicitHeight + 8
                    radius: 2
                    color: connectMa.pressed ? Theme.highlightMed : Theme.highlightLow
                    opacity: MusicService.authenticating ? 0.5 : 1
                    Text {
                        id: connectLbl; anchors.centerIn: parent
                        text: MusicService.authenticating ? "Connecting…" : "Connect"
                        font.family: Theme.font; font.pixelSize: 12; color: Theme.foam
                    }
                    MouseArea {
                        id: connectMa
                        anchors.fill: parent
                        enabled: !MusicService.authenticating
                        cursorShape: Qt.PointingHandCursor
                        onClicked: MusicService.startAuth()
                    }
                }
            }

            Text {
                visible: MusicService.authenticating
                text: openMa.pressed ? "Opening…" : "Open browser again"
                font.family: Theme.font; font.pixelSize: 11; font.underline: true
                color: Theme.foam
                MouseArea {
                    id: openMa
                    anchors.fill: parent
                    anchors.margins: -6
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MusicService.openAuthBrowser()
                }
            }
        }
    }

    Component {
        id: libraryComponent

        Item {
            width: root.width
            height: root.bodyHeight

            ColumnLayout {
                id: playerBar
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 4

                Text {
                    Layout.fillWidth: true
                    text: MusicService.active ? MusicService.title : "Nothing playing"
                    font.family: Theme.font; font.pixelSize: 13; font.bold: true; color: Theme.text
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: MusicService.artist !== ""
                    text: MusicService.artist
                    font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                    elide: Text.ElideRight
                }

                Text {
                    Layout.fillWidth: true
                    visible: MusicService.playError !== ""
                    text: MusicService.playError
                    font.family: Theme.font; font.pixelSize: 11; color: Theme.love
                    wrapMode: Text.WordWrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 6
                    visible: MusicService.active && MusicService.duration > 0

                    Text {
                        text: MusicService.formatTime(timeSlider._dragging
                            ? timeSlider.value / 100 * MusicService.duration
                            : MusicService.position)
                        font.family: Theme.font; font.pixelSize: 10; color: Theme.subtle
                        Layout.preferredWidth: 34
                        horizontalAlignment: Text.AlignRight
                    }

                    VolumeSlider {
                        id: timeSlider
                        Layout.fillWidth: true
                        liveUpdate: false
                        inputValue: MusicService.duration > 0
                            ? MusicService.position / MusicService.duration * 100 : 0
                        onMoved: MusicService.seek(value / 100 * MusicService.duration)
                    }

                    Text {
                        text: MusicService.formatTime(MusicService.duration)
                        font.family: Theme.font; font.pixelSize: 10; color: Theme.subtle
                        Layout.preferredWidth: 34
                    }
                }

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 20

                        Item {
                            implicitWidth: 36
                            implicitHeight: 36
                            Text {
                                anchors.centerIn: parent
                                text: "⏮"
                                font.pixelSize: 22
                                color: Theme.text
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MusicService.prevTrack()
                            }
                        }

                        Item {
                            implicitWidth: 40
                            implicitHeight: 40
                            Text {
                                anchors.centerIn: parent
                                text: MusicService.paused ? "▶" : "⏸"
                                font.pixelSize: 26
                                color: Theme.foam
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MusicService.playPause()
                            }
                        }

                        Item {
                            implicitWidth: 36
                            implicitHeight: 36
                            Text {
                                anchors.centerIn: parent
                                text: "⏭"
                                font.pixelSize: 22
                                color: Theme.text
                            }
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MusicService.nextTrack()
                            }
                        }
                    }

                    Item {
                        width: 36
                        height: 36
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        visible: MusicService.queueLength > 1
                        Text {
                            anchors.centerIn: parent
                            text: MusicService.shuffle ? "🔀" : "🔁"
                            font.pixelSize: 18
                            color: MusicService.shuffle ? Theme.iris : Theme.subtle
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MusicService.setShuffle(!MusicService.shuffle)
                        }
                    }
                }
            }

            Rectangle {
                id: playerDivider
                anchors.top: playerBar.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Theme.highlightMed
            }

            RowLayout {
                id: tabRow
                anchors.top: playerDivider.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                spacing: 12

                Text {
                    text: "Search"
                    font.family: Theme.font; font.pixelSize: 12
                    font.bold: root.activeTab === "search"
                    color: root.activeTab === "search" ? Theme.iris : Theme.subtle
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.activeTab = "search"
                            MusicService.closePlaylist()
                            Qt.callLater(() => searchInput.forceActiveFocus())
                        }
                    }
                }

                Text {
                    text: "Playlists"
                    font.family: Theme.font; font.pixelSize: 12
                    font.bold: root.activeTab === "playlists"
                    color: root.activeTab === "playlists" ? Theme.iris : Theme.subtle
                    MouseArea {
                        anchors.fill: parent; anchors.margins: -6
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.activeTab = "playlists"
                            if (MusicService.playlists.length === 0 && !MusicService.loadingPlaylists)
                                MusicService.loadPlaylists()
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }

            Flickable {
                id: bodyFlick
                anchors.top: tabRow.bottom
                anchors.topMargin: 8
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                contentHeight: bodyColumn.implicitHeight

                ColumnLayout {
                    id: bodyColumn
                    width: bodyFlick.width
                    spacing: 10

                    Connections {
                        target: MusicService
                        function onMusicInputFocusTickChanged() {
                            if (root.activeTab === "search")
                                Qt.callLater(() => searchInput.forceActiveFocus())
                        }
                    }

                    Connections {
                        target: ShellGlobals
                        function onOpenPopupChanged() {
                            if (ShellGlobals.openPopup === "music" && root.activeTab === "search")
                                Qt.callLater(() => searchInput.forceActiveFocus())
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        visible: root.activeTab === "search"

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: searchInput.implicitHeight + 10

                            Timer {
                                id: searchDebounce
                                interval: 350
                                onTriggered: MusicService.search(searchInput.text)
                            }

                            TextInput {
                                id: searchInput
                                anchors.fill: parent
                                focus: true
                                activeFocusOnTab: true
                                leftPadding: 6; rightPadding: 6; topPadding: 5; bottomPadding: 5
                                font.family: Theme.font; font.pixelSize: 12; color: Theme.text
                                onTextChanged: {
                                    if (text.trim().length === 0) {
                                        searchDebounce.stop()
                                        MusicService.search("")
                                    } else {
                                        searchDebounce.restart()
                                    }
                                }
                                Keys.onPressed: event => {
                                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                                        searchDebounce.stop()
                                        MusicService.search(searchInput.text)
                                        event.accepted = true
                                    }
                                }
                                onVisibleChanged: if (visible) forceActiveFocus()
                                Rectangle { anchors.fill: parent; z: -1; color: Theme.highlightMed; radius: 4 }
                                Text {
                                    visible: searchInput.text.length === 0 && !searchInput.activeFocus
                                    anchors.left: parent.left; anchors.leftMargin: 6; anchors.verticalCenter: parent.verticalCenter
                                    text: "Search any song…"
                                    font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                propagateComposedEvents: true
                                onPressed: mouse => {
                                    searchInput.forceActiveFocus()
                                    mouse.accepted = false
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: MusicService.searching
                            text: "Searching…"
                            font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: !MusicService.searching && MusicService.searchError !== ""
                            text: MusicService.searchError
                            font.family: Theme.font; font.pixelSize: 11; color: Theme.love
                            wrapMode: Text.WordWrap
                        }

                        Repeater {
                            model: MusicService.searchResults

                            ColumnLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                spacing: 0

                                Item {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 44

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: MusicService.playSong(modelData.videoId)
                                    }

                                    RowLayout {
                                        anchors.left: parent.left
                                        anchors.right: parent.right
                                        anchors.verticalCenter: parent.verticalCenter
                                        spacing: 8

                                        Text { text: "▶"; font.pixelSize: 10; color: Theme.foam }

                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            spacing: 0

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.title
                                                font.family: Theme.font; font.pixelSize: 13; color: Theme.text
                                                elide: Text.ElideRight
                                            }

                                            Text {
                                                Layout.fillWidth: true
                                                text: modelData.artist + (modelData.duration ? " · " + modelData.duration : "")
                                                font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                                                elide: Text.ElideRight
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: !MusicService.searching && searchInput.text.trim() !== "" && MusicService.searchResults.length === 0 && MusicService.searchError === ""
                            text: "No results"
                            font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: root.activeTab === "playlists"

                        Text {
                            visible: MusicService.selectedPlaylistId !== ""
                            text: "← Back"
                            font.family: Theme.font; font.pixelSize: 11; color: Theme.foam
                            MouseArea {
                                anchors.fill: parent; anchors.margins: -6
                                cursorShape: Qt.PointingHandCursor
                                onClicked: MusicService.closePlaylist()
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: MusicService.selectedPlaylistId !== ""
                            text: MusicService.selectedPlaylistTitle
                            font.family: Theme.font; font.pixelSize: 13; font.bold: true; color: Theme.text
                            elide: Text.ElideRight
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            visible: MusicService.selectedPlaylistId !== "" && MusicService.playlistTracks.length > 0
                            spacing: 8

                            Text {
                                text: "Shuffle"
                                font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                            }

                            Rectangle {
                                implicitWidth: 36; implicitHeight: 20
                                radius: 10
                                color: MusicService.shuffle ? Theme.iris : Theme.highlightMed
                                Rectangle {
                                    x: MusicService.shuffle ? parent.width - width - 2 : 2
                                    anchors.verticalCenter: parent.verticalCenter
                                    width: 16; height: 16; radius: 8
                                    color: Theme.text
                                    Behavior on x { NumberAnimation { duration: 150 } }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MusicService.setShuffle(!MusicService.shuffle)
                                }
                            }

                            Item { Layout.fillWidth: true }

                            Text {
                                visible: MusicService.queueLength > 1
                                text: `${MusicService.queuePosition}/${MusicService.queueLength}`
                                font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: MusicService.selectedPlaylistId === "" && MusicService.loadingPlaylists
                            text: "Loading playlists…"
                            font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: MusicService.selectedPlaylistId === "" && !MusicService.loadingPlaylists && MusicService.playlistsError !== ""
                            text: MusicService.playlistsError
                            font.family: Theme.font; font.pixelSize: 11; color: Theme.love
                            wrapMode: Text.WordWrap
                        }

                        Repeater {
                            model: MusicService.selectedPlaylistId === "" ? MusicService.playlists : []

                            Item {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: playlistRow.implicitHeight + 8

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MusicService.openPlaylist(modelData.playlistId, modelData.title)
                                }

                                RowLayout {
                                    id: playlistRow
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Text { text: "♫"; font.pixelSize: 11; color: Theme.foam }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.title
                                            font.family: Theme.font; font.pixelSize: 13; color: Theme.text
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.count ? `${modelData.count} songs` : "Playlist"
                                            font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: MusicService.selectedPlaylistId === "" && !MusicService.loadingPlaylists && MusicService.playlists.length === 0 && MusicService.playlistsError === ""
                            text: "No playlists found"
                            font.family: Theme.font; font.pixelSize: 12; color: Theme.muted
                            horizontalAlignment: Text.AlignHCenter
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: MusicService.selectedPlaylistId !== "" && MusicService.loadingPlaylistTracks
                            text: "Loading songs…"
                            font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                        }

                        Text {
                            Layout.fillWidth: true
                            visible: MusicService.selectedPlaylistId !== "" && !MusicService.loadingPlaylistTracks && MusicService.playlistTracksError !== ""
                            text: MusicService.playlistTracksError
                            font.family: Theme.font; font.pixelSize: 11; color: Theme.love
                            wrapMode: Text.WordWrap
                        }

                        Repeater {
                            model: MusicService.selectedPlaylistId !== "" ? MusicService.playlistTracks : []

                            Item {
                                required property var modelData
                                Layout.fillWidth: true
                                implicitHeight: trackRow.implicitHeight + 6

                                property bool isPlaying: MusicService.active && MusicService.videoId === modelData.videoId

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: MusicService.playPlaylistFrom(modelData.videoId)
                                }

                                RowLayout {
                                    id: trackRow
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Text {
                                        text: parent.parent.isPlaying ? "♪" : String(index + 1)
                                        font.family: Theme.font; font.pixelSize: 11
                                        color: parent.parent.isPlaying ? Theme.iris : Theme.muted
                                        Layout.preferredWidth: 18
                                        horizontalAlignment: Text.AlignHCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        spacing: 0

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.title
                                            font.family: Theme.font; font.pixelSize: 12
                                            font.bold: parent.parent.isPlaying
                                            color: parent.parent.isPlaying ? Theme.iris : Theme.text
                                            elide: Text.ElideRight
                                        }

                                        Text {
                                            Layout.fillWidth: true
                                            text: modelData.artist + (modelData.duration ? " · " + modelData.duration : "")
                                            font.family: Theme.font; font.pixelSize: 11; color: Theme.subtle
                                            elide: Text.ElideRight
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
