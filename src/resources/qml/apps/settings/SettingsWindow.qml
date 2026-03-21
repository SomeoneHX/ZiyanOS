import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ZiyanOS.SettingsManager
import ZiyanOS

ZiyanWindow {
    id: settingsWindow
    width: 800
    height: 600
    windowTitle: "设置"

    titleBarColor: contentBackground  // 使用新的ZiyanWindow颜色机制

    // 当前设置 - 从设置管理器获取
    property string currentBackground: settingsManager ? settingsManager.desktopBackground : "#1a1a1a"
    property string currentWallpaper: settingsManager ? settingsManager.desktopWallpaper : ""
    property string currentWindowMode: settingsManager ? settingsManager.windowTitleBarMode : "auto"
    property string currentWindowColor: settingsManager ? settingsManager.windowTitleBarColor : "#3498db"

    // 信号：壁纸改变时通知桌面更新
    signal wallpaperChanged(string background, string wallpaperPath)
    // 新增：窗口设置改变信号
    signal windowSettingsChanged(string mode, string color)

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

                    // 壁纸选项
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: settingsStack.currentIndex === 1 ? "#34495e" : "transparent"

                        Text {
                            text: "壁纸"
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

                    // 新增：窗口选项
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: settingsStack.currentIndex === 2 ? "#34495e" : "transparent"

                        Text {
                            text: "窗口"
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

                    // 分辨率选项
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: settingsStack.currentIndex === 3 ? "#34495e" : "transparent"

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
                                settingsStack.currentIndex = 3
                            }
                        }
                    }

                    // 网络
                    Rectangle {
                        width: parent.width
                        height: 50
                        color: settingsStack.currentIndex === 4 ? "#34495e" : "transparent"

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
                                settingsStack.currentIndex = 4
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

                        // 关于页面 - 使用独立的组件
                        AboutPage {
                            width: parent.width
                        }

                        // 壁纸页面 - 使用独立的组件
                        WallpaperPage {
                            width: parent.width
                            currentBackground: settingsWindow.currentBackground
                            currentWallpaper: settingsWindow.currentWallpaper
                            settingsManager: settingsWindow.settingsManager

                            onWallpaperChanged: {
                                settingsWindow.wallpaperChanged(background, wallpaperPath)
                            }
                        }

                        // 新增：窗口设置页面
                        WindowSettingsPage {
                            width: parent.width
                            currentWindowMode: settingsWindow.currentWindowMode
                            currentWindowColor: settingsWindow.currentWindowColor

                            onWindowSettingsChanged: (mode, color) => {
                                console.log("窗口设置改变，模式:", mode, "颜色:", color)
                                // 更新设置管理器
                                settingsManager.windowTitleBarMode = mode
                                settingsManager.windowTitleBarColor = color
                                settingsManager.saveSettings()

                                // 更新当前值以便预览
                                settingsWindow.currentWindowMode = mode
                                settingsWindow.currentWindowColor = color

                                // 通知桌面更新所有窗口
                                if (typeof desktop !== 'undefined' && desktop.updateWindowSettings) {
                                    desktop.updateWindowSettings()
                                }
                            }
                        }

                        // 新增：分辨率设置页面
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
                // 通过桌面创建彩蛋窗口
                if (typeof desktop !== 'undefined') {
                    desktop.createApplicationWindow("easteregg")
                } else {
                    console.warn("无法找到桌面对象，无法创建彩蛋窗口")
                }
            })
        }
        // 初始化时设置为关于页面
        settingsStack.currentIndex = 0
        console.log("壁纸目录:", settingsManager.getWallpaperDir())
        console.log("窗口设置加载完成 - 模式:", currentWindowMode, "颜色:", currentWindowColor)
    }
}
