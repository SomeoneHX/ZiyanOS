import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia
import ZiyanOS.FileSystem
import ZiyanOS

ZiyanWindow {
    id: musicPlayer
    width: 400
    height: 400
    windowTitle: "音乐播放器"
    contentBackground: "#2c3e50"

    property string currentMusicPath: ""
    property var fileSystem: FileSystem {}
    property var filePicker: null


    // 添加：标记是否正在关闭
    property bool isClosing: false

    // 音频播放器
    MediaPlayer {
        id: mediaPlayer
        audioOutput: AudioOutput {
            id: audioOutput
            volume: 0.5
        }
        onPlaybackStateChanged: {
            // 如果正在关闭，忽略状态更新
            if (!isClosing) {
                updatePlayButton()
                updatePositionInfo()
            }
        }
        onPositionChanged: {
            if (!isClosing) {
                updateProgress()
            }
        }
        onDurationChanged: {
            if (!isClosing) {
                updatePositionInfo()
                progressSlider.to = duration
            }
        }
    }

    // 窗口关闭时的处理
    onWindowClosing: {
        console.log("音乐播放器窗口关闭，停止播放")
        isClosing = true
        stopMusic()

        // 确保媒体资源被释放
        mediaPlayer.source = ""
    }

    // 组件销毁时的清理
    Component.onDestruction: {
        console.log("音乐播放器组件销毁，清理资源")
        if (mediaPlayer.playbackState !== MediaPlayer.StoppedState) {
            mediaPlayer.stop()
        }
        mediaPlayer.source = ""
    }

    contentItem: Item {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 20

            // 音乐信息区域 - 移到顶部
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                // 歌曲标题
                Text {
                    id: songTitle
                    text: currentMusicPath === "" ? "未选择音乐" : getFileName(currentMusicPath)
                    color: "white"
                    font.pixelSize: 18
                    font.bold: true
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                // 艺术家信息
                Text {
                    id: artistInfo
                    text: mediaPlayer.playbackState === MediaPlayer.PlayingState ? "正在播放" :
                          mediaPlayer.playbackState === MediaPlayer.PausedState ? "已暂停" : "已停止"
                    color: "#bdc3c7"
                    font.pixelSize: 14
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }

                // 时间信息
                Text {
                    id: timeInfo
                    text: formatTime(mediaPlayer.position) + " / " + formatTime(mediaPlayer.duration)
                    color: "#95a5a6"
                    font.pixelSize: 12
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            // 进度条
            Slider {
                id: progressSlider
                Layout.fillWidth: true
                from: 0
                to: mediaPlayer.duration
                value: mediaPlayer.position
                enabled: mediaPlayer.playbackState !== MediaPlayer.StoppedState && !isClosing

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 6
                    color: "#34495e"
                    radius: 3
                }

                handle: Rectangle {
                    x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                    y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                    implicitWidth: 16
                    implicitHeight: 16
                    radius: 8
                    color: progressSlider.pressed ? "#3498db" : "#ecf0f1"
                    border.color: "#3498db"
                }

                onMoved: {
                    if (!isClosing) {
                        mediaPlayer.position = value
                    }
                }
            }

            // 控制按钮区域
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                // 打开按钮
                Rectangle {
                    width: 50
                    height: 50
                    color: "#3498db"
                    radius: 25

                    Text {
                        text: "📁"
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!isClosing) {
                                showMusicPicker()
                            }
                        }
                    }
                }

                // 播放/暂停按钮
                Rectangle {
                    id: playPauseButton
                    width: 60
                    height: 60
                    color: "#27ae60"
                    radius: 30

                    Text {
                        id: playPauseIcon
                        text: "▶"
                        color: "white"
                        font.pixelSize: 24
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!isClosing) {
                                togglePlayPause()
                            }
                        }
                    }
                }

                // 停止按钮
                Rectangle {
                    width: 50
                    height: 50
                    color: "#e74c3c"
                    radius: 25

                    Text {
                        text: "⏹"
                        font.pixelSize: 20
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if (!isClosing) {
                                stopMusic()
                            }
                        }
                    }
                }
            }

            // 音量控制
            RowLayout {
                Layout.fillWidth: true
                spacing: 10

                Text {
                    text: "🔈"
                    font.pixelSize: 16
                    color: "#bdc3c7"
                }

                Slider {
                    id: volumeSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 1
                    value: audioOutput.volume

                    background: Rectangle {
                        implicitWidth: 200
                        implicitHeight: 4
                        color: "#34495e"
                        radius: 2
                    }

                    handle: Rectangle {
                        x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                        y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                        implicitWidth: 12
                        implicitHeight: 12
                        radius: 6
                        color: volumeSlider.pressed ? "#3498db" : "#ecf0f1"
                        border.color: "#3498db"
                    }

                    onMoved: {
                        if (!isClosing) {
                            audioOutput.volume = value
                        }
                    }
                }

                Text {
                    text: "🔊"
                    font.pixelSize: 16
                    color: "#bdc3c7"
                }
            }

            // 文件信息
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: "#34495e"
                radius: 8
                visible: currentMusicPath !== "" && !isClosing

                Column {
                    anchors.centerIn: parent
                    spacing: 5
                    width: parent.width - 20

                    Text {
                        text: "文件: " + getFileName(currentMusicPath)
                        color: "white"
                        font.pixelSize: 12
                        elide: Text.ElideMiddle
                        width: parent.width
                    }

                    Text {
                        text: "路径: " + currentMusicPath
                        color: "#bdc3c7"
                        font.pixelSize: 10
                        elide: Text.ElideMiddle
                        width: parent.width
                    }
                }
            }
        }
    }

    // 显示音乐选择器
    function showMusicPicker() {
        if (isClosing) return

        filePicker = filePickerComponent.createObject(musicPlayer, {
            "selectFolder": false,
            "fileFilters": [".mp3", ".wav", ".ogg", ".flac", ".aac", ".m4a"],
            "fileMode": "open"
        })

        filePicker.fileSelected.connect(function(path) {
            if (!isClosing) {
                loadMusic(path)
            }
            filePicker.destroy()
        })

        filePicker.canceled.connect(function() {
            filePicker.destroy()
        })

        filePicker.showWindow()
    }

    // 加载音乐
    function loadMusic(path) {
        // 如果正在关闭，不加载新音乐
        if (isClosing) return

        console.log("加载音乐: " + path)
        currentMusicPath = path
        musicPlayer.windowTitle = "音乐播放器 - " + getFileName(path)
        mediaPlayer.source = "file:///" + path
        playMusic()
    }

    // 播放音乐
    function playMusic() {
        if (currentMusicPath !== "" && !isClosing) {
            mediaPlayer.play()
        }
    }

    // 暂停/恢复音乐
    function togglePlayPause() {
        if (currentMusicPath === "" || isClosing) return

        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
            mediaPlayer.pause()
        } else {
            mediaPlayer.play()
        }
    }

    // 停止音乐
    function stopMusic() {
        if (mediaPlayer.playbackState !== MediaPlayer.StoppedState) {
            mediaPlayer.stop()
        }
    }

    // 更新播放按钮状态
    function updatePlayButton() {
        if (isClosing) return

        if (mediaPlayer.playbackState === MediaPlayer.PlayingState) {
            playPauseIcon.text = "⏸"
            playPauseButton.color = "#f39c12"
        } else {
            playPauseIcon.text = "▶"
            playPauseButton.color = "#27ae60"
        }
    }

    // 更新进度条
    function updateProgress() {
        if (!progressSlider.pressed && !isClosing) {
            progressSlider.value = mediaPlayer.position
        }
    }

    // 更新时间信息
    function updatePositionInfo() {
        if (!isClosing) {
            timeInfo.text = formatTime(mediaPlayer.position) + " / " + formatTime(mediaPlayer.duration)
        }
    }

    // 格式化时间（毫秒转换为分:秒）
    function formatTime(milliseconds) {
        if (!milliseconds || isNaN(milliseconds)) return "00:00"

        var seconds = Math.floor(milliseconds / 1000)
        var minutes = Math.floor(seconds / 60)
        seconds = seconds % 60

        return minutes.toString().padStart(2, '0') + ":" + seconds.toString().padStart(2, '0')
    }

    // 获取文件名
    function getFileName(path) {
        if (!path) return ""
        var lastSlash = Math.max(path.lastIndexOf('\\'), path.lastIndexOf('/'))
        return path.substring(lastSlash + 1)
    }

    // 公共方法：打开音乐文件
    function openMusic(path) {
        console.log("音乐播放器 openMusic 被调用，路径:", path)
        if (path && typeof path === 'string') {
            Qt.callLater(function() {
                loadMusic(path)
            })
        } else {
            console.log("无效的文件路径参数")
        }
    }

    // 文件选择器组件
    Component {
        id: filePickerComponent
        FilePicker {}
    }

    // 键盘快捷键
    Keys.onPressed: (event) => {
        if (isClosing) return

        switch(event.key) {
            case Qt.Key_Space:
                togglePlayPause()
                break
            case Qt.Key_O:
                if (event.modifiers & Qt.ControlModifier) {
                    showMusicPicker()
                }
                break
            case Qt.Key_S:
                stopMusic()
                break
        }
    }

    Component.onCompleted: {
        forceActiveFocus()
    }
}
