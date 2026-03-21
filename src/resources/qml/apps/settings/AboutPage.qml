import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import ZiyanOS.Apps 1.0

Item {
    id: aboutPage
    implicitHeight: aboutContent.height

    // 信号：连续点击5次版本号时触发
    signal easterEggTriggered()

    Column {
        id: aboutContent
        width: parent.width
        spacing: 30
        padding: 40

        // Logo容器
        Item {
            id: logoContainer
            width: 360
            height: 100
            anchors.horizontalCenter: parent.horizontalCenter

            Rectangle {
                id: logoBackground
                anchors.centerIn: parent
                width: 360
                height: 100
                radius: 15
                color: "Black"
                z: 0
            }

            AnimatedImage {
                id: bootAnimation
                source: "qrc:/qt/qml/ZiyanOS/src/resources/assets/logo_animation.gif"
                width: 300
                height: 100
                anchors.centerIn: parent
                fillMode: Image.PreserveAspectFit
                smooth: true
                z: 1
                playing: true

                // 当当前帧变化时，检查是否为最后一帧，若是则停止播放
                onCurrentFrameChanged: {
                    if (frameCount > 0 && currentFrame === frameCount - 1) {
                        playing = false
                    }
                }
            }

            DropShadow {
                anchors.fill: logoBackground
                horizontalOffset: 2
                verticalOffset: 2
                radius: 8.0
                samples: 16
                color: "#80000000"
                source: logoBackground
                z: -1
            }
        }

        // 版本信息 - 可点击，用于触发彩蛋
        MouseArea {
            id: versionClickArea
            width: versionText.width
            height: versionText.height
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                versionClickCounter++
                console.log("版本号被点击，次数:", versionClickCounter)

                if (versionClickCounter >= 5) {
                    console.log("触发彩蛋！")
                    versionClickCounter = 0
                    easterEggTriggered()
                } else {
                    resetTimer.restart()
                }
            }

            property int versionClickCounter: 0

            Timer {
                id: resetTimer
                interval: 3000
                onTriggered: {
                    versionClickArea.versionClickCounter = 0
                    console.log("点击计数已重置")
                }
            }

            Text {
                id: versionText
                text: "版本 NEXT 2.0\n开发版本"
                color: "#7f8c8d"
                font.pixelSize: 16
            }
        }

        // 分隔线
        Rectangle {
            width: 200
            height: 1
            color: "#dee2e6"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // 开发者信息
        Column {
            spacing: 8
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: "哔哩哔哩"
                color: "#2c3e50"
                font.pixelSize: 14
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Text {
                text: "某哔用户"
                color: "#3498db"
                font.pixelSize: 16
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }
        }

        // ========= 感谢支持区域 =========
        Rectangle {
            width: 200
            height: 1
            color: "#dee2e6"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "感谢以下项目的支持"
            color: "#2c3e50"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Column {
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 80

            // 条目：hwl
            Row {
                spacing: 15
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "HardwareLab"
                        color: "#2c3e50"
                        font.pixelSize: 16
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    Text {
                        text: "提供精神支持。"
                        color: "#7f8c8d"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }
            }

            // 条目：deepseek
            Row {
                spacing: 15
                width: parent.width

                Column {
                    width: parent.width
                    spacing: 4
                    anchors.verticalCenter: parent.verticalCenter

                    Text {
                        text: "deepseek"
                        color: "#2c3e50"
                        font.pixelSize: 16
                        font.bold: true
                        elide: Text.ElideRight
                        width: parent.width
                    }
                    Text {
                        text: "提供代码"
                        color: "#7f8c8d"
                        font.pixelSize: 14
                        elide: Text.ElideRight
                        width: parent.width
                    }
                }
            }
        }
        // ======================================

        // 开源协议区域
        Rectangle {
            width: 200
            height: 1
            color: "#dee2e6"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: "开源协议"
            color: "#2c3e50"
            font.pixelSize: 18
            font.bold: true
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // 协议列表（网格布局，两列）
        Grid {
            columns: 2
            spacing: 20
            anchors.horizontalCenter: parent.horizontalCenter

            Repeater {
                model: [
                    { name: "libcurl (MIT)", file: "libcurl_MIT.txt" },
                    { name: "Noto Color Emoji (OFL)", file: "NotoColorEmoji_OFL.txt" },
                    { name: "Qt (LGPL)", file: "Qt_LGPL.txt" },
                    { name: "思源黑体 (OFL)", file: "SourceHanSans_OFL.txt" }
                ]

                delegate: Rectangle {
                    width: 200
                    height: 40
                    color: "#ecf0f1"
                    radius: 5
                    border.color: "#bdc3c7"

                    Text {
                        text: modelData.name
                        color: "#2c3e50"
                        font.pixelSize: 14
                        anchors.centerIn: parent
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var filePath = applicationDirPath + "/licenses/" + modelData.file
                            console.log("打开协议文件:", filePath)

                            // 使用应用管理器启动文本编辑器
                            if (typeof AppRegistry !== 'undefined') {
                                AppRegistry.launchApp("texteditor", {
                                    filePath: filePath,
                                    readOnly: true
                                })
                            } else {
                                console.warn("AppRegistry 未定义，无法打开协议文件")
                            }
                        }
                    }
                }
            }
        }
    }
}