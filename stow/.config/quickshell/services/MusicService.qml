pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import ".."

QtObject {
    id: root

    property string _scriptsDir: Quickshell.env("HOME") + "/.config/quickshell/scripts"
    property string _apiScript: root._scriptsDir + "/music-api.py"
    property string _playerScript: root._scriptsDir + "/music-player.py"

    property bool checkingAuth: true
    property bool authenticated: false
    property bool authenticating: false
    property string authError: ""

    property bool active: false
    property bool paused: false
    property string title: ""
    property string artist: ""
    property real position: 0
    property real duration: 0
    property string videoId: ""
    property bool shuffle: false
    property int queueLength: 0
    property int queuePosition: 0

    property var searchResults: []
    property bool searching: false
    property string searchError: ""

    property var playlists: []
    property bool loadingPlaylists: false
    property string playlistsError: ""

    property string selectedPlaylistId: ""
    property string selectedPlaylistTitle: ""
    property var playlistTracks: []
    property bool loadingPlaylistTracks: false
    property string playlistTracksError: ""

    property bool playingItem: false
    property string playError: ""

    property int musicInputFocusTick: 0

    function focusMusicSearch() {
        root.musicInputFocusTick++
    }

    function _parseJson(text) {
        try {
            return JSON.parse(text)
        } catch (_) {
            return null
        }
    }

    function _parseJsonResponse(text) {
        const lines = text.trim().split("\n").filter(line => line.trim().length > 0)
        for (let i = lines.length - 1; i >= 0; i--) {
            const data = root._parseJson(lines[i])
            if (data) return data
        }
        return null
    }

    function _parsePlayerSnapshot(text) {
        const data = root._parseJson(text)
        if (!data) return
        root.active = !!data.active
        root.paused = !!data.paused
        root.title = data.title || ""
        root.artist = data.artist || ""
        root.position = data.position || 0
        root.duration = data.duration || 0
        root.videoId = data.videoId || ""
        root.shuffle = !!data.shuffle
        root.queueLength = data.queueLength || 0
        root.queuePosition = data.queuePosition || 0
    }

    property var _playerBuffer: []
    property var _playerListener: Process {
        command: ["bash", root._scriptsDir + "/listen-music.sh"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: line => {
                if (line === "---") {
                    if (root._playerBuffer.length > 0)
                        root._parsePlayerSnapshot(root._playerBuffer.join("\n"))
                    root._playerBuffer = []
                } else {
                    root._playerBuffer.push(line)
                }
            }
        }
    }

    property Component _procComponent: Component {
        Process {
            id: proc
            property var capturedStdout: ""
            property var capturedStderr: ""
            stdout: SplitParser {
                splitMarker: "\n"
                onRead: line => proc.capturedStdout += (proc.capturedStdout ? "\n" : "") + line
            }
            stderr: SplitParser {
                splitMarker: "\n"
                onRead: line => proc.capturedStderr += line
            }
            onExited: exitCode => {
                finished(exitCode)
                destroy()
            }
            signal finished(int exitCode)
        }
    }

    function _runApi(args, onDone) {
        const p = root._procComponent.createObject(root, {
            command: ["python3", root._apiScript].concat(args)
        })
        p.finished.connect(exitCode => {
            const data = root._parseJsonResponse(p.capturedStdout)
            if (!data) {
                onDone(exitCode, null, p.capturedStderr || "invalid response")
            } else {
                onDone(exitCode, data, data.message || p.capturedStderr)
            }
        })
        p.running = true
        return p
    }

    function _runPlayer(args, onDone) {
        const p = root._procComponent.createObject(root, {
            command: ["python3", root._playerScript].concat(args)
        })
        p.finished.connect(exitCode => {
            const data = root._parseJson(p.capturedStdout.trim())
            onDone(exitCode, data, (data && data.message) || p.capturedStderr)
        })
        p.running = true
        return p
    }

    function refreshAuth() {
        root.checkingAuth = true
        root.authError = ""
        root._runApi(["status"], (exitCode, data) => {
            root.checkingAuth = false
            if (!data) {
                root.authenticated = false
                root.authError = "music api unavailable"
                return
            }
            root.authenticated = data.status === "authed"
            if (data.status === "noauth")
                root.authError = data.message || ""
            if (root.authenticated)
                root.loadPlaylists()
        })
    }

    Component.onCompleted: root.refreshAuth()

    function startAuth() {
        root.authError = ""
        root.authenticating = true
        root._runApi(["browser-auth-sync"], (exitCode, data, err) => {
            if (data && data.status === "ok") {
                root.authenticating = false
                root.authError = ""
                root.authenticated = true
                root.loadPlaylists()
                return
            }
            root._runApi(["browser-auth-start"], (startCode, startData, startErr) => {
                if (startCode !== 0 || !startData || startData.status !== "ok") {
                    root.authenticating = false
                    root.authError = startErr || err || "failed to start browser sign-in"
                    return
                }
                root._authPollTimer.start()
            })
        })
    }

    function openAuthBrowser() {
        const p = Qt.createQmlObject('import Quickshell.Io; Process { onExited: destroy() }', root)
        p.command = ["xdg-open", "https://music.youtube.com"]
        p.running = true
    }

    property var _authPollTimer: Timer {
        interval: 2000
        repeat: true
        onTriggered: root._pollAuth()
    }

    function _pollAuth() {
        root._runApi(["browser-auth-poll"], (exitCode, data, err) => {
            if (!data) {
                root.authenticating = false
                root._authPollTimer.stop()
                root.authError = err || "sign-in failed"
                return
            }
            if (data.status === "pending")
                return
            root._authPollTimer.stop()
            root.authenticating = false
            if (data.status === "ok") {
                root.authError = ""
                root.authenticated = true
                root.loadPlaylists()
            } else {
                root.authError = err || "sign-in failed"
            }
        })
    }

    function search(query) {
        const q = (query || "").trim()
        if (!q) {
            root.searchResults = []
            root.searchError = ""
            return
        }
        root.searching = true
        root.searchError = ""
        root._runApi(["search", q, "--limit", "3"], (exitCode, data, err) => {
            root.searching = false
            if (!data || data.status !== "ok") {
                root.searchResults = []
                root.searchError = err || "search failed"
                return
            }
            const results = data.results || []
            root.searchResults = results.length > 0 ? results.slice(0) : []
            root.searchError = ""
        })
    }

    function loadPlaylists() {
        if (!root.authenticated) return
        root.loadingPlaylists = true
        root.playlistsError = ""
        root._runApi(["playlists"], (exitCode, data, err) => {
            root.loadingPlaylists = false
            if (exitCode !== 0 || !data || data.status !== "ok") {
                root.playlists = []
                root.playlistsError = err || "failed to load playlists"
                return
            }
            root.playlists = data.playlists || []
        })
    }

    function openPlaylist(playlistId, title) {
        if (!playlistId) return
        root.selectedPlaylistId = playlistId
        root.selectedPlaylistTitle = title || ""
        root.playlistTracks = []
        root.playlistTracksError = ""
        root.loadingPlaylistTracks = true
        root._runApi(["playlist-tracks", playlistId], (exitCode, data, err) => {
            root.loadingPlaylistTracks = false
            if (exitCode !== 0 || !data || data.status !== "ok") {
                root.playlistTracks = []
                root.playlistTracksError = err || "failed to load playlist"
                return
            }
            root.selectedPlaylistTitle = data.title || root.selectedPlaylistTitle
            root.playlistTracks = data.tracks || []
        })
    }

    function closePlaylist() {
        root.selectedPlaylistId = ""
        root.selectedPlaylistTitle = ""
        root.playlistTracks = []
        root.playlistTracksError = ""
    }

    function playSong(videoId) {
        if (!videoId) return
        root.playError = ""
        root.playingItem = true
        root._runPlayer(["play", "--video-id", videoId], (exitCode, data, err) => {
            root.playingItem = false
            if (exitCode !== 0 || !data || data.status !== "ok")
                root.playError = err || "failed to play song"
        })
    }

    function playPlaylistFrom(videoId) {
        if (!videoId || root.playlistTracks.length === 0) return
        const ids = root.playlistTracks.map(track => track.videoId).filter(Boolean)
        const index = Math.max(0, ids.indexOf(videoId))
        root.playError = ""
        root.playingItem = true
        root._runPlayer(
            ["play-queue", "--video-ids", ids.join(","), "--index", String(index), "--shuffle", root.shuffle ? "true" : "false"],
            (exitCode, data, err) => {
                root.playingItem = false
                if (exitCode !== 0 || !data || data.status !== "ok")
                    root.playError = err || "failed to play playlist"
            }
        )
    }

    function setShuffle(enabled) {
        root.shuffle = enabled
        root._runPlayer(["set-shuffle", enabled ? "true" : "false"], (exitCode, data, err) => {
            if (exitCode !== 0 || !data || data.status !== "ok") {
                root.playError = err || "failed to update shuffle"
                return
            }
            if (data.shuffle !== undefined)
                root.shuffle = !!data.shuffle
        })
    }

    function playPause() {
        root._runPlayer(["control", "play-pause"], () => {})
    }

    function nextTrack() {
        root._runPlayer(["control", "next"], () => {})
    }

    function prevTrack() {
        root._runPlayer(["control", "prev"], () => {})
    }

    function seek(seconds) {
        root._runPlayer(["seek", String(seconds)], () => {})
    }

    function formatTime(seconds) {
        const total = Math.max(0, Math.floor(seconds || 0))
        const mins = Math.floor(total / 60)
        const secs = total % 60
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}
