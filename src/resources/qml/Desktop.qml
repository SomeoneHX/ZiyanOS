import QtQuick
import QtQuick.Controls
import QtQuick.Window
import ZiyanOS.SettingsManager
import ZiyanOS.SystemUtils
import Qt5Compat.GraphicalEffects
import ZiyanOS

ApplicationWindow {
    id: desktop
    width: Screen.width
    height: Screen.height
    visible: false
    flags: Qt.FramelessWindowHint
    title: "字研OS 桌面"

    // 关键修改：添加一个属性来标记是否允许关闭
    property bool allowClose: false

    // 窗口管理器引用
    property var windowManager: null

    // 添加SystemUtils
    SystemUtils {
        id: systemUtils
    }

    // 添加设置管理器
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

    // 壁纸属性 - 从设置管理器获取
    property string desktopBackground: settingsManager.desktopBackground
    property string desktopWallpaper: settingsManager.desktopWallpaper

    // 存储打开的窗口
    property var openWindows: []

    property var compatModeWindow: null  // 当前兼容模式窗口
    property var hiddenWindows: []        // 存储隐藏的窗口对象

    // 桌面背景
    Rectangle {
        anchors.fill: parent
        id: desktopBackgroundRect
        color: desktopWallpaper === "" ? desktopBackground : "transparent"

        // 如果设置了壁纸图片，显示图片
        Image {
            anchors.fill: parent
            source: desktopWallpaper
            fillMode: Image.PreserveAspectCrop
            visible: desktopWallpaper !== ""
        }

        // 桌面图标区域 - GridView 布局实现竖向排列和自动换列
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

            delegate: Item {
                width: desktopIcons.cellWidth
                height: desktopIcons.cellHeight

                DesktopIcon {
                    iconText: model.iconText || "🌐"
                    iconName: model.iconName || "应用"
                    anchors.centerIn: parent

                    onClicked: {
                        createApplicationWindow(model.appType || "")
                    }
                }
            }

            model: ListModel {
                id: desktopIconsModel
            }

            Component.onCompleted: {
                var systemApps = [
                    { iconText: "🌐", iconName: "浏览器", appType: "browser", appId: "browser" },
                    { iconText: "📁", iconName: "文件浏览器", appType: "filebrowser", appId: "filebrowser" },
                    { iconText: "🧮", iconName: "计算器", appType: "calculator", appId: "calculator" },
                    { iconText: "📝", iconName: "文本编辑器", appType: "texteditor", appId: "texteditor" },
                    { iconText: "🖼️", iconName: "图片查看器", appType: "imageviewer", appId: "imageviewer" },
                    { iconText: "🎵", iconName: "音乐播放器", appType: "musicplayer", appId: "musicplayer" },
                    { iconText: "🎬", iconName: "视频播放器", appType: "videoplayer", appId: "videoplayer" },
                    { iconText: "⬇️", iconName: "下载管理器", appType: "downloadmanager", appId: "downloadmanager" },
                    { iconText: "🍷", iconName: "Windows兼容层", appType: "winecompat", appId: "winecompat" },
                    { iconText: "⚙️", iconName: "设置", appType: "settings", appId: "settings" }
                ]

                for (var i = 0; i < systemApps.length; i++) {
                    desktopIconsModel.append(systemApps[i])
                }
            }
        }

        // 打开的窗口容器
        Item {
            id: windowsContainer
            anchors.fill: parent
        }
    }

    // 任务栏（含高斯模糊背景）
    Item {
        id: taskbar
        width: parent.width
        height: 60  // 增加高度以容纳更大图标
        anchors.bottom: parent.bottom

        // 截取任务栏区域的桌面背景作为模糊源
        ShaderEffectSource {
            id: blurSource
            sourceItem: desktopBackgroundRect
            sourceRect: Qt.rect(0, desktop.height - taskbar.height, taskbar.width, taskbar.height)
            live: true
        }

        // 高斯模糊效果（只显示在任务栏区域）
        GaussianBlur {
            anchors.fill: parent
            source: blurSource
            radius: 8
            samples: 16
        }

        // 半透明颜色覆盖层
        Rectangle {
            anchors.fill: parent
            color: "#2c3e50"
            opacity: 0.6
        }

        // 任务栏图标行 - 现在在整个任务栏中居中
        Row {
            id: taskbarApps
            spacing: 8
            anchors.centerIn: parent  // 水平垂直居中
        }

        // 任务栏右侧 - 日期、时间、锁屏和电源（保持不变）
        Row {
            id: systemTray
            spacing: 15
            anchors {
                right: parent.right
                rightMargin: 15
                verticalCenter: parent.verticalCenter
            }

            // 日期和时间显示
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
                        createApplicationWindow("power")
                    }
                }
            }
        }
    }

    // 修改壁纸改变的处理函数
    function handleWallpaperChanged(background, wallpaperPath) {
        console.log("壁纸改变:", background, wallpaperPath)
        settingsManager.desktopBackground = background
        settingsManager.desktopWallpaper = wallpaperPath
        settingsManager.saveSettings()
    }

    // 组件定义（所有应用窗口组件）
    Component {
        id: textEditorWindowComponent
        TextEditor {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: powerWindowComponent
        PowerWindow {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: browserWindowComponent
        BrowserWindow {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: fileBrowserWindowComponent
        FileBrowserWindow {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: calculatorWindowComponent
        CalculatorWindow {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: imageViewerWindowComponent
        ImageViewer {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: musicPlayerWindowComponent
        MusicPlayer {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: videoPlayerWindowComponent
        VideoPlayer {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: downloadManagerWindowComponent
        DownloadManagerWindow {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: wineCompatLayerComponent
        WineCompatLayer {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    Component {
        id: settingsWindowComponent
        SettingsWindow {
            onWindowClosing: {
                removeWindow(this)
            }
            onWallpaperChanged: (background, wallpaperPath) => {
                desktop.handleWallpaperChanged(background, wallpaperPath)
            }
        }
    }

    // 彩蛋窗口组件
    Component {
        id: easterEggWindowComponent
        EasterEggWindow {
            onWindowClosing: {
                removeWindow(this)
            }
        }
    }

    // 获取应用图标
    function getAppIcon(appType) {
        switch(appType) {
            case "browser": return "🌐"
            case "filebrowser": return "📁"
            case "calculator": return "🧮"
            case "texteditor": return "📝"
            case "imageviewer": return "🖼️"
            case "musicplayer": return "🎵"
            case "videoplayer": return "🎬"
            case "downloadmanager": return "⬇️"
            case "settings": return "⚙️"
            case "winecompat": return "🍷️"
            case "power": return "🔌"
            case "easteregg": return "🥚"
            default: return "📄"
        }
    }

    // 更新日期和时间
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

    // 创建应用窗口
    function createApplicationWindow(type, additionalParam) {
        var window
        var windowId = type + "_" + Date.now()
        var appIcon = getAppIcon(type)

        switch(type) {
            case "power":
                if (desktop.windowManager) {
                    desktop.windowManager.switchToPowerMenu()
                    return
                }
                window = powerWindowComponent.createObject(desktop)
                window.requestDesktopClose.connect(function() {
                    allowClose = true
                    Qt.quit()
                })
                break
            case "browser":
                var initialUrl = ""
                var isLocalFile = false

                if (typeof additionalParam === 'object' && additionalParam !== null) {
                    initialUrl = additionalParam.url || ""
                    isLocalFile = additionalParam.isLocalFile || false
                } else {
                    initialUrl = additionalParam || ""
                }

                window = browserWindowComponent.createObject(desktop, {
                    "initialUrl": initialUrl,
                    "isLocalFile": isLocalFile,
                    "desktop": desktop,
                    "settingsManager": settingsManager
                })
                break
            case "filebrowser":
                window = fileBrowserWindowComponent.createObject(desktop)
                break
            case "calculator":
                window = calculatorWindowComponent.createObject(desktop)
                break
            case "winecompat":
                window = wineCompatLayerComponent.createObject(desktop, {
                    "desktop": desktop
                })
                break
            case "texteditor":
                var filePath = "";
                var readOnly = false;
                if (typeof additionalParam === 'object' && additionalParam !== null) {
                    filePath = additionalParam.filePath || "";
                    readOnly = additionalParam.readOnly || false;
                } else {
                    filePath = additionalParam || "";
                }
                window = textEditorWindowComponent.createObject(desktop, {
                    "readOnly": readOnly
                });
                if (filePath && window.openFile) {
                    Qt.callLater(function() {
                        window.openFile(filePath);
                    });
                }
                break;
            case "imageviewer":
                window = imageViewerWindowComponent.createObject(desktop)
                if (additionalParam && window.openImage) {
                    Qt.callLater(function() {
                        window.openImage(additionalParam)
                    })
                }
                break
            case "musicplayer":
                window = musicPlayerWindowComponent.createObject(desktop)
                if (additionalParam && window.openMusic) {
                    Qt.callLater(function() {
                        window.openMusic(additionalParam)
                    })
                }
                break
            case "settings":
                window = settingsWindowComponent.createObject(desktop, {
                    "currentBackground": desktopBackground,
                    "currentWallpaper": desktopWallpaper,
                    "settingsManager": settingsManager,
                    "desktop": desktop
                })
                break
            case "videoplayer":
                window = videoPlayerWindowComponent.createObject(desktop)
                if (additionalParam && window.openVideo) {
                    Qt.callLater(function() {
                        window.openVideo(additionalParam)
                    })
                }
                break
            case "downloadmanager":
                var downloadUrl = ""
                if (additionalParam) {
                    if (typeof additionalParam === 'object' && additionalParam !== null) {
                        downloadUrl = additionalParam.url || ""
                    } else {
                        downloadUrl = additionalParam
                    }
                }
                window = downloadManagerWindowComponent.createObject(desktop, {
                    "initialUrl": downloadUrl
                })
                break
            case "easteregg":
                window = easterEggWindowComponent.createObject(desktop)
                break
            default:
                console.log("未知的窗口类型: " + type)
                return
        }

        if (window) {
            if (window.settingsManager !== undefined) {
                window.settingsManager = settingsManager
            }

            if (window.globalWindowMode !== undefined) {
                window.globalWindowMode = settingsManager.windowTitleBarMode || "auto"
                window.globalWindowColor = settingsManager.windowTitleBarColor || "#3498db"
            }
            window.showWindow()
            openWindows.push({
                "window": window,
                "id": windowId,
                "type": type,
                "title": window.windowTitle,  // 存储窗口标题用于任务栏提示
                "icon": appIcon
            })
            updateTaskbar()
        }
    }

    // 进入兼容模式
    function enterCompatMode(compatWindow) {
        if (compatModeWindow) return
        compatModeWindow = compatWindow

        for (var i = openWindows.length - 1; i >= 0; i--) {
            var winInfo = openWindows[i]
            if (winInfo.window !== compatWindow) {
                winInfo.window.close()
            }
        }

        desktop.visible = false

        if (!compatWindow.visible) {
            compatWindow.showWindow()
        } else {
            compatWindow.raise()
            compatWindow.requestActivate()
        }
    }

    // 退出兼容模式
    function exitCompatMode() {
        if (!compatModeWindow) return
        compatModeWindow = null

        desktop.visible = true
        desktop.raise()
        desktop.requestActivate()
    }

    // 移除窗口
    function removeWindow(window) {
        for (var i = 0; i < openWindows.length; i++) {
            if (openWindows[i].window === window) {
                openWindows.splice(i, 1)
                updateTaskbar()
                break
            }
        }
    }

    // 切换到窗口
    function activateWindow(index) {
        if (index >= 0 && index < openWindows.length) {
            var window = openWindows[index].window
            window.requestActivate()
            window.raise()
        }
    }

    // 任务栏按钮组件 - 增加工具提示显示应用名称
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
            property string windowTitle: ""  // 新增属性，用于工具提示

            // 图标
            Text {
                text: windowIcon
                color: "white"
                font.pixelSize: 28
                anchors.centerIn: parent
            }

            // 鼠标悬停效果
            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                color: "#7f8c8d"
                opacity: 0
                Behavior on opacity { NumberAnimation { duration: 200 } }
            }

            // 鼠标区域，用于悬停检测和点击
            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                onEntered: button.color = "#34495e"
                onExited: button.color = "transparent"
                onClicked: {
                    var windowInfo = desktop.openWindows[windowIndex]
                    if (windowInfo) {
                        if (windowInfo.window.isMinimized)
                            windowInfo.window.restoreWindow()
                        else
                            windowInfo.window.minimizeWindow()
                    }
                }
            }

            // 工具提示：鼠标悬停时显示应用名称
            ToolTip {
                visible: mouseArea.containsMouse && windowTitle !== ""
                text: windowTitle
                delay: 100
                timeout: -1  // 不自动隐藏，鼠标移出即消失
                // 设置提示显示在按钮上方
                y: -height - 5
                x: (parent.width - width) / 2
            }
        }
    }

    function updateWindowSettings() {
        for (var i = 0; i < openWindows.length; i++) {
            var window = openWindows[i].window
            if (window && window.globalWindowMode !== undefined) {
                window.globalWindowMode = settingsManager.windowTitleBarMode
                window.globalWindowColor = settingsManager.windowTitleBarColor

                if (window.settingsManager !== undefined) {
                    window.settingsManager = settingsManager
                }
            }
        }
    }

    function updateTaskbar() {
        // 清空任务栏图标行
        for (var i = taskbarApps.children.length - 1; i >= 0; i--) {
            taskbarApps.children[i].destroy()
        }
        // 重新为每个打开的窗口创建按钮，并传递窗口标题
        for (var j = 0; j < openWindows.length; j++) {
            var windowInfo = openWindows[j]
            taskbarButtonComponent.createObject(taskbarApps, {
                "windowIndex": j,
                "windowIcon": windowInfo.icon,
                "windowTitle": windowInfo.title  // 传递窗口标题
            })
        }
    }

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

    onClosing: (close) => {
        console.log("Desktop window closing event triggered, allowClose:", allowClose)

        if (!allowClose) {
            close.accepted = false

            var hasPowerWindow = false
            for (var i = 0; i < openWindows.length; i++) {
                if (openWindows[i].type === "power") {
                    hasPowerWindow = true
                    openWindows[i].window.raise()
                    openWindows[i].window.requestActivate()
                    break
                }
            }

            if (!hasPowerWindow) {
                console.log("Alt+F4 pressed, showing power window. Has power window:", hasPowerWindow)
                createApplicationWindow("power")
            }
        } else {
            close.accepted = true
            console.log("允许关闭桌面应用")
        }
    }
}
