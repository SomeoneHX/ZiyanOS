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
    }

    property string desktopBackground: settingsManager.desktopBackground

    // 背景
    Rectangle {
        anchors.fill: parent
        id: desktopBackgroundRect
        color: desktopBackground

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
            bottomMargin: 60

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

    // 激活指定索引的窗口
    function activateWindow(index) {
        var window = AppRegistry.getWindowByIndex(index)
        if (window) {
            window.requestActivate()
            window.raise()
        }
    }

    // 组件完成时初始化
    Component.onCompleted: {
        console.log("加载持久化设置")
        settingsManager.loadSettings()

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