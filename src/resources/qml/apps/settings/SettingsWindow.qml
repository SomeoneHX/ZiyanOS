import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ZiyanOS.SettingsManager
import ZiyanOS
import ZiyanOS.Apps 1.0

ZiyanWindow {
    id: settingsWindow
    width: 800
    height: 600
    windowTitle: "设置"

    contentItem: Item {
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            spacing: 0

            // 左侧侧边栏
            Rectangle {
                id: sidebar
                Layout.preferredWidth: 200
                Layout.fillHeight: true
                color: "#2c3e50"
                z: 10

                Column {
                    width: parent.width
                    spacing: 1

                    // 关于选项
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: settingsStack.currentIndex === 0 ? "#34495e" : "transparent"

                        Text {
                            text: "关于"
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsStack.currentIndex = 0
                            }
                        }
                    }

                    // 分辨率选项
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: settingsStack.currentIndex === 1 ? "#34495e" : "transparent"

                        Text {
                            text: "分辨率"
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsStack.currentIndex = 1
                            }
                        }
                    }

                    // 网络
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: settingsStack.currentIndex === 2 ? "#34495e" : "transparent"

                        Text {
                            text: "网络"
                            color: "white"
                            font.pixelSize: 14
                            font.bold: true
                            anchors.centerIn: parent
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                settingsStack.currentIndex = 2
                            }
                        }
                    }
                }
            }

            // 右侧内容区域
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "#ecf0f1"

                ScrollView {
                    id: scrollView
                    anchors.fill: parent
                    clip: true

                    StackLayout {
                        id: settingsStack
                        width: scrollView.width
                        currentIndex: 0

                        // 关于页面
                        AboutPage {
                            width: parent.width
                        }

                        // 分辨率设置页面
                        ResolutionPage {
                            width: parent.width
                        }

                        NetworkPage {
                            width: parent.width
                        }

                        onCurrentIndexChanged: {
                            // 重置滚动位置到顶部
                            if (scrollView.contentItem && scrollView.contentItem.contentY !== undefined) {
                                scrollView.contentItem.contentY = 0
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        // 监听彩蛋触发信号
        var aboutPage = settingsStack.itemAt(0)
        if (aboutPage) {
            aboutPage.easterEggTriggered.connect(function() {
                console.log("彩蛋信号触发，创建彩蛋窗口")
                // 通过应用管理器启动彩蛋
                if (typeof AppRegistry !== 'undefined') {
                    AppRegistry.launchApp("easteregg", {})
                } else {
                    console.warn("无法找到 AppRegistry，无法创建彩蛋窗口")
                }
            })
        }
        settingsStack.currentIndex = 0
    }
}