import QtQuick
import QtQuick.Controls
import QtQuick.Window
import ZiyanOS.SettingsManager
import ZiyanOS.SystemUtils
import Qt5Compat.GraphicalEffects
import ZiyanOS
import ZiyanOS.Apps 1.0

ApplicationWindow {
    id: desktop
    width: Screen.width
    height: Screen.height
    // visible: false
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnBottomHint
    visibility: Window.FullScreen
    title: "字研OS 桌面"

    property bool allowClose: false
    property var windowManager: null

    SystemUtils {
        id: systemUtils
    }

    SettingsManager {
        id: settingsManager
        onDesktopBackgroundChanged: function(background) {
            console.log("桌面背景改变:", background)
            desktopBackground = background
        }
        onDesktopWallpaperChanged: function(wallpaper) {
            console.log("桌面壁纸改变:", wallpaper)
            desktopWallpaper = wallpaper
        }
        onWindowTitleBarModeChanged: function(mode) {
            console.log("窗口模式改变:", mode)
            updateWindowSettings()
        }
        onWindowTitleBarColorChanged: function(color) {
            console.log("窗口颜色改变:", color)
            updateWindowSettings()
        }
    }

    property string desktopBackground: settingsManager.desktopBackground
    property string desktopWallpaper: settingsManager.desktopWallpaper

    // 背景
    Rectangle {
        anchors.fill: parent
        id: desktopBackgroundRect
        color: desktopWallpaper === "" ? desktopBackground : "transparent"

        Image {
            anchors.fill: parent
            source: desktopWallpaper
            fillMode: Image.PreserveAspectCrop
            visible: desktopWallpaper !== ""
        }

        // 桌面图标区域：使用 AppRegistry 的应用模型
        GridView {
            id: desktopIcons
            anchors {
                top: parent.top
                topMargin: 30
                left: parent.left
                leftMargin: 30
                right: parent.right
                bottom: parent.bottom
            }
            flow: GridView.FlowTopToBottom
            cellWidth: 100
            cellHeight: 100
            layoutDirection: Qt.LeftToRight
            interactive: false

            model: AppRegistry.appModel

            delegate: DesktopIcon {
                visible: model.desktopVisible !== false
                iconText: model.displayIcon || "📄"
                iconName: model.name
                onClicked: {
                    AppRegistry.launchApp(model.appId, {})
                }
            }
        }

        // 打开的窗口容器（保留用于兼容，但不再手动管理）
        Item {
            id: windowsContainer
            anchors.fill: parent
        }
    }

    // 任务栏
    Item {
        id: taskbar
        width: parent.width
        height: 60
        anchors.bottom: parent.bottom

        Rectangle {
            anchors.fill: parent
            color: "#2c3e50"
            opacity: 0.6
        }

        // 任务栏图标行：动态绑定活动窗口模型
        Row {
            id: taskbarApps
            spacing: 8
            anchors.centerIn: parent

            Repeater {
                model: AppRegistry.activeWindowsModel
                delegate: Rectangle {
                    id: button
                    width: 48; height: 48
                    radius: 6
                    color: "transparent"

                    property int windowIndex: index

                    Text {
                        text: model.displayIcon || "📄"
                        color: "white"
                        font.pixelSize: 28
                        anchors.centerIn: parent
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: "#7f8c8d"
                        opacity: 0
                        Behavior on opacity { NumberAnimation { duration: 200 } }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: button.color = "#34495e"
                        onExited: button.color = "transparent"
                        onClicked: {
                            var window = AppRegistry.getWindowByIndex(windowIndex)
                            if (window) {
                                if (window.isMinimized)
                                    window.restoreWindow()
                                else
                                    window.minimizeWindow()
                            }
                        }
                    }

                    ToolTip {
                        visible: mouseArea.containsMouse && model.title !== ""
                        text: model.title
                        delay: 100
                        timeout: -1
                        y: -height - 5
                        x: (parent.width - width) / 2
                    }
                }
            }
        }

        // 系统托盘（日期、锁屏、电源）
        Row {
            id: systemTray
            spacing: 15
            anchors {
                right: parent.right
                rightMargin: 15
                verticalCenter: parent.verticalCenter
            }

            Column {
                spacing: 2
                anchors.verticalCenter: parent.verticalCenter

                Text {
                    id: dateText
                    color: "white"
                    font.pixelSize: 12
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                }

                Text {
                    id: timeText
                    color: "white"
                    font.pixelSize: 14
                    font.bold: true
                    horizontalAlignment: Text.AlignRight
                }
            }

            // 锁屏按钮
            Rectangle {
                width: 36
                height: 36
                radius: 4
                color: "transparent"
                border.color: "transparent"

                Rectangle {
                    id: lockScreenHoverBg
                    anchors.fill: parent
                    radius: parent.radius
                    color: "#7f8c8d"
                    opacity: 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                }

                Text {
                    text: "🔒"
                    color: "white"
                    font.pixelSize: 18
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: lockScreenHoverBg.opacity = 1
                    onExited: lockScreenHoverBg.opacity = 0
                    onClicked: {
                        if (desktop.windowManager && desktop.windowManager.switchToLockScreen) {
                            desktop.windowManager.switchToLockScreen()
                        }
                    }
                }
            }

            // 电源按钮
            Rectangle {
                width: 36
                height: 36
                radius: 4
                color: "transparent"

                Text {
                    text: "🔌"
                    color: "white"
                    font.pixelSize: 18
                    anchors.centerIn: parent
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: parent.color = "#e74c3c"
                    onExited: parent.color = "transparent"
                    onClicked: {
                        if (desktop.windowManager && desktop.windowManager.switchToPowerMenu) {
                            desktop.windowManager.switchToPowerMenu()
                        }
                    }
                }
            }
        }
    }

    // 日期时间更新定时器
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            var currentTime = new Date()
            dateText.text = currentTime.toLocaleDateString(Qt.locale(), "yyyy-MM-dd dddd")
            timeText.text = currentTime.toLocaleTimeString(Qt.locale(), "hh:mm:ss")
        }
    }

    // 任务栏按钮组件
    Component {
        id: taskbarButtonComponent

        Rectangle {
            id: button
            width: 48
            height: 48
            radius: 6
            color: "transparent"

            property int windowIndex: -1
            property string windowIcon: "📄"
            property string windowTitle: ""

            Text {
                text: windowIcon
                color: "white"
                font.pixelSize: 28
                anchors.centerIn: parent
            }

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "#7f8c8d"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: button.color = "#34495e"
                onExited: button.color = "transparent"
                onClicked: {
                    var window = AppRegistry.getWindowByIndex(windowIndex)
                    if (window) {
                        if (window.isMinimized)
                            window.restoreWindow()
                        else
                            window.minimizeWindow()
                    }
                }
            }

            ToolTip {
                visible: mouseArea.containsMouse && windowTitle !== ""
                text: windowTitle
                delay: 100
                timeout: -1
                y: -height - 5
                x: (parent.width - width) / 2
            }
        }
    }

    // 更新所有窗口的外观设置（遍历活动窗口）
    function updateWindowSettings() {
        var count = AppRegistry.activeWindowsModel.rowCount()
        for (var i = 0; i < count; i++) {
            var window = AppRegistry.getWindowByIndex(i)
            if (window && window.globalWindowMode !== undefined) {
                window.globalWindowMode = settingsManager.windowTitleBarMode
                window.globalWindowColor = settingsManager.windowTitleBarColor
                if (window.settingsManager !== undefined) {
                    window.settingsManager = settingsManager
                }
            }
        }
    }

    // 激活指定索引的窗口
    function activateWindow(index) {
        var window = AppRegistry.getWindowByIndex(index)
        if (window) {
            window.requestActivate()
            window.raise()
        }
    }

    // 壁纸变化处理（由设置页面调用）
    function handleWallpaperChanged(background, wallpaperPath) {
        console.log("壁纸改变:", background, wallpaperPath)
        settingsManager.desktopBackground = background
        settingsManager.desktopWallpaper = wallpaperPath
        settingsManager.saveSettings()
    }

    // 组件完成时初始化
    Component.onCompleted: {
        var currentTime = new Date()
        dateText.text = currentTime.toLocaleDateString(Qt.locale(), "yyyy-MM-dd dddd")
        timeText.text = currentTime.toLocaleTimeString(Qt.locale(), "hh:mm:ss")

        console.log("加载持久化壁纸设置")
        settingsManager.loadSettings()

        settingsManager.windowTitleBarModeChanged.connect(function(mode) {
            console.log("窗口模式改变:", mode)
            updateWindowSettings()
        })
        settingsManager.windowTitleBarColorChanged.connect(function(color) {
            console.log("窗口颜色改变:", color)
            updateWindowSettings()
        })

        visible = true
        raise()
        requestActivate()
    }

    // 窗口关闭处理（Alt+F4）
    onClosing: (close) => {
        console.log("Desktop window closing event triggered, allowClose:", allowClose)

        if (!allowClose) {
            close.accepted = false

            // 检查是否已有电源菜单打开（通过活动窗口模型判断）
            var hasPowerWindow = false
            var count = AppRegistry.activeWindowsModel.rowCount()
            for (var i = 0; i < count; i++) {
                var window = AppRegistry.getWindowByIndex(i)
                if (window && window.appId === "power") {
                    hasPowerWindow = true
                    window.raise()
                    window.requestActivate()
                    break
                }
            }

            if (!hasPowerWindow && windowManager) {
                console.log("Alt+F4 pressed, showing power window.")
                windowManager.switchToPowerMenu()
            }
        } else {
            close.accepted = true
            console.log("允许关闭桌面应用")
        }
    }
}